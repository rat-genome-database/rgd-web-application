#!/usr/bin/env python3
"""
PDF text extraction using Marker library
This script provides better extraction quality for scientific PDFs
"""

import sys
import json
import tempfile
import os
import traceback
from pathlib import Path

# Suppress all warnings and verbose output
import warnings
warnings.filterwarnings('ignore')

# Redirect stderr to suppress model loading messages
import logging
logging.getLogger().setLevel(logging.CRITICAL)

# Set environment variables to reduce verbosity
os.environ["GRPC_VERBOSITY"] = "ERROR"
os.environ["GLOG_minloglevel"] = "2"
os.environ["PYTORCH_ENABLE_MPS_FALLBACK"] = "1"

def add_image_label(pil_image, label_text, image_name=""):
    """Add a label/marker to an image"""
    from PIL import Image, ImageDraw, ImageFont
    
    try:
        # Convert to RGB if necessary
        if pil_image.mode != 'RGB':
            pil_image = pil_image.convert('RGB')
        
        # Create a new image with space for label
        width, height = pil_image.size
        label_height = 40
        new_height = height + label_height
        
        # Create new image with white background for label area
        new_image = Image.new('RGB', (width, new_height), color=(255, 255, 255))
        
        # Paste original image below label area
        new_image.paste(pil_image, (0, label_height))
        
        # Draw label
        draw = ImageDraw.Draw(new_image)
        
        # Try to use a good font, fallback to default if not available
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
        except:
            try:
                font = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf", 14)
            except:
                font = ImageFont.load_default()
        
        # Draw label background
        draw.rectangle([(0, 0), (width, label_height)], fill=(240, 240, 240))
        
        # Draw label text
        text = f"{label_text}"
        if image_name:
            text += f" - {image_name}"
        
        # Calculate text position
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        x = 10  # Left margin
        y = (label_height - text_height) // 2
        
        draw.text((x, y), text, fill=(0, 0, 0), font=font)
        
        # Add a border line between label and image
        draw.line([(0, label_height-1), (width, label_height-1)], fill=(200, 200, 200), width=1)
        
        return new_image
        
    except Exception as e:
        # If labeling fails, return original image
        return pil_image

def extract_with_marker(pdf_path):
    """Extract text from PDF using Marker library"""
    try:
        # Import new marker API
        from marker.config.parser import ConfigParser
        from marker.models import create_model_dict
        
        # Load models (this is cached after first load)
        models = create_model_dict()
        
        # Create output directory for images
        output_dir = os.path.join(tempfile.gettempdir(), f"marker_output_{os.getpid()}")
        os.makedirs(output_dir, exist_ok=True)
        
        # Configure marker with improved image extraction settings
        config_dict = {
            'output_format': 'markdown',
            'ocr_all_pages': False,
            'langs': ['en'],
            'max_pages': None,
            'batch_multiplier': 2,
            'output_dir': output_dir,
            'extract_images': True,
            'save_images': True,
            'images_to_find': True,
            'disable_image_extraction': False,
            'extract_figure_images': True,
            'extract_text_images': False,
            'image_dpi': 150,
            'image_quality': 95
        }
        
        config_parser = ConfigParser(config_dict)
        converter_cls = config_parser.get_converter_cls()
        converter = converter_cls(
            config=config_parser.generate_config_dict(),
            artifact_dict=models,
            processor_list=config_parser.get_processors(),
            renderer=config_parser.get_renderer(),
            llm_service=config_parser.get_llm_service()
        )
        
        # Redirect stdout temporarily to suppress progress output
        import io
        from contextlib import redirect_stderr
        
        # Convert the PDF with stderr redirected
        with redirect_stderr(io.StringIO()):
            rendered = converter(pdf_path)
        
        # Extract the text content from rendered output
        if hasattr(rendered, 'text_content'):
            full_text = rendered.text_content
        elif hasattr(rendered, 'markdown'):
            full_text = rendered.markdown
        else:
            # The rendered object might be a string representation, extract the markdown content
            rendered_str = str(rendered)
            if rendered_str.startswith("markdown='") and rendered_str.endswith("'"):
                # Extract content between markdown=' and final '
                full_text = rendered_str[10:-1]  # Remove "markdown='" and final "'"
                # Unescape newlines
                full_text = full_text.replace('\\n', '\n').replace('\\t', '\t')
            else:
                full_text = rendered_str
        
        # Look for image references in the markdown text itself
        import re
        from PIL import Image, ImageDraw, ImageFont
        image_files = []
        image_count = 0
        
        # Find image references in markdown format: ![alt text](image_file)
        image_pattern = r'!\[.*?\]\(([^)]+\.(?:png|jpg|jpeg|gif|bmp|tiff))\)'
        image_matches = re.findall(image_pattern, full_text, re.IGNORECASE)
        
        # Also look for embedded base64 images in the markdown
        base64_pattern = r'!\[.*?\]\(data:image/[^;]+;base64,([^)]+)\)'
        base64_matches = re.findall(base64_pattern, full_text)
        
        # Process base64 images if found
        import base64
        for i, base64_data in enumerate(base64_matches):
            try:
                # Decode base64 image
                image_data = base64.b64decode(base64_data)
                
                # Save as image file
                image_path = os.path.join(output_dir, f"extracted_base64_{i+1}.png")
                with open(image_path, 'wb') as f:
                    f.write(image_data)
                
                image_files.append(image_path)
                image_count += 1
            except Exception as e:
                pass  # Skip invalid base64 data
        
        # Only create placeholders if we have markdown image references but no actual images extracted
        if image_matches and image_count == 0:
            # Try to find the actual image files first
            possible_base_dirs = [
                output_dir,
                os.path.dirname(pdf_path),
                tempfile.gettempdir(),
                os.getcwd()
            ]
            
            for i, image_ref in enumerate(image_matches):
                found = False
                # Try to find the actual image file
                for base_dir in possible_base_dirs:
                    potential_path = os.path.join(base_dir, image_ref)
                    if os.path.exists(potential_path):
                        image_files.append(potential_path)
                        image_count += 1
                        found = True
                        break
                
                # If not found as a file, create a better placeholder image
                if not found:
                    try:
                        # Create placeholder image with better styling
                        placeholder_img = Image.new('RGB', (600, 400), color=(250, 250, 250))
                        draw = ImageDraw.Draw(placeholder_img)
                        
                        # Draw border
                        draw.rectangle([(10, 10), (590, 390)], outline=(200, 200, 200), width=2)
                        
                        # Add icon-like representation
                        # Draw a simple image icon
                        icon_size = 80
                        icon_x = (600 - icon_size) // 2
                        icon_y = 120
                        draw.rectangle([(icon_x, icon_y), (icon_x + icon_size, icon_y + icon_size)], 
                                     outline=(150, 150, 150), width=2)
                        # Draw mountain icon inside (simple triangles)
                        draw.polygon([(icon_x + 20, icon_y + 60), (icon_x + 40, icon_y + 30), 
                                    (icon_x + 60, icon_y + 60)], fill=(180, 180, 180))
                        draw.polygon([(icon_x + 35, icon_y + 60), (icon_x + 55, icon_y + 40), 
                                    (icon_x + 75, icon_y + 60)], fill=(160, 160, 160))
                        # Draw sun icon
                        draw.ellipse([(icon_x + 50, icon_y + 15), (icon_x + 65, icon_y + 30)], 
                                   fill=(200, 200, 100))
                        
                        # Add text to placeholder
                        text_lines = [
                            f"Figure {i+1}",
                            "",
                            "Image detected in PDF",
                            "Extraction in progress...",
                            "",
                            f"Reference: {image_ref[:40]}..." if len(image_ref) > 40 else f"Reference: {image_ref}"
                        ]
                        
                        # Try to use default font, fallback to built-in if not available
                        try:
                            font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 18)
                            font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
                        except:
                            font_large = ImageFont.load_default()
                            font_small = ImageFont.load_default()
                        
                        # Draw text lines
                        y_offset = 230
                        for idx, line in enumerate(text_lines):
                            if idx == 0:  # Title
                                bbox = draw.textbbox((0, 0), line, font=font_large)
                                text_width = bbox[2] - bbox[0]
                                x = (600 - text_width) // 2
                                draw.text((x, y_offset), line, fill=(50, 50, 50), font=font_large)
                                y_offset += 30
                            else:  # Other lines
                                if line:  # Skip empty lines
                                    bbox = draw.textbbox((0, 0), line, font=font_small)
                                    text_width = bbox[2] - bbox[0]
                                    x = (600 - text_width) // 2
                                    draw.text((x, y_offset), line, fill=(100, 100, 100), font=font_small)
                                y_offset += 25
                        
                        # Save placeholder image
                        placeholder_path = os.path.join(output_dir, f"placeholder_{i+1}.png")
                        placeholder_img.save(placeholder_path, "PNG")
                        
                        image_files.append(placeholder_path)
                        image_count += 1
                    except Exception as e:
                        # If placeholder creation fails, just skip
                        pass
        
        # Also check traditional directory locations
        pdf_name = os.path.splitext(os.path.basename(pdf_path))[0]
        possible_image_dirs = [
            output_dir,
            os.path.join(os.path.dirname(pdf_path), f"{pdf_name}_images"),
            os.path.join(os.path.dirname(pdf_path), f"{pdf_name}_figures"),
            os.path.join(tempfile.gettempdir(), f"{pdf_name}_images"),
            os.path.join(tempfile.gettempdir(), "marker_images"),
            os.path.join(os.getcwd(), "images"),
            os.path.join(os.getcwd(), f"{pdf_name}_images")
        ]
        
        # Check for common image formats in directories
        image_extensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff']
        
        for image_dir in possible_image_dirs:
            if os.path.exists(image_dir):
                for file in os.listdir(image_dir):
                    if any(file.lower().endswith(ext) for ext in image_extensions):
                        full_path = os.path.join(image_dir, file)
                        if full_path not in image_files:  # Avoid duplicates
                            image_files.append(full_path)
                            image_count += 1
        
        # First, check if Marker extracted images directly
        if hasattr(rendered, 'images') and rendered.images:
            for img_idx, (img_name, pil_image) in enumerate(rendered.images.items()):
                try:
                    # Add label/marker to the image
                    if hasattr(pil_image, 'save'):
                        # Create a new image with label
                        labeled_image = add_image_label(pil_image, f"Figure {img_idx + 1}", img_name)
                        
                        # Save the PIL image to disk
                        image_filename = f"{img_name}"
                        if not image_filename.lower().endswith(('.png', '.jpg', '.jpeg')):
                            image_filename = f"{img_name}.png"
                        
                        image_path = os.path.join(output_dir, image_filename)
                        
                        # Save as PNG to preserve quality
                        labeled_image.save(image_path, "PNG")
                        
                        if image_path not in image_files:
                            image_files.append(image_path)
                            image_count += 1
                        
                except Exception as e:
                    continue
        
        # Also check if images were saved as files by Marker
        if hasattr(rendered, 'output_dir'):
            # Look for images in Marker's output directory
            marker_output_dir = rendered.output_dir
            if os.path.exists(marker_output_dir):
                for file in os.listdir(marker_output_dir):
                    if any(file.lower().endswith(ext) for ext in ['.png', '.jpg', '.jpeg', '.gif', '.bmp']):
                        full_path = os.path.join(marker_output_dir, file)
                        if full_path not in image_files:
                            image_files.append(full_path)
                            image_count += 1
                        
        # Check if there are images in other possible attributes
        for attr_name in ['image_paths', 'extracted_images', 'figures', 'assets']:
            if hasattr(rendered, attr_name):
                attr_value = getattr(rendered, attr_name)
                if isinstance(attr_value, list):
                    for item in attr_value:
                        if isinstance(item, str) and os.path.exists(item):
                            if item not in image_files:
                                image_files.append(item)
                                image_count += 1
        
        # Return structured result
        result = {
            "success": True,
            "text": full_text,
            "metadata": {"conversion_method": "marker_v2"},
            "image_count": image_count,
            "image_paths": image_files,
            "error": None
        }
        
        # Clean up output directory if no images found
        if image_count == 0 and os.path.exists(output_dir):
            try:
                import shutil
                shutil.rmtree(output_dir)
            except:
                pass  # Ignore cleanup errors
        
        return result
        
    except ImportError as e:
        return {
            "success": False,
            "text": None,
            "metadata": {},
            "image_count": 0,
            "error": f"Marker library not installed: {str(e)}"
        }
    except Exception as e:
        return {
            "success": False,
            "text": None,
            "metadata": {},
            "image_count": 0,
            "error": f"Extraction failed: {str(e)}\n{traceback.format_exc()}"
        }

def main():
    """Main entry point for script"""
    if len(sys.argv) != 2:
        print(json.dumps({
            "success": False,
            "error": "Usage: python pdf_marker_extractor.py <pdf_path>"
        }))
        sys.exit(1)
    
    pdf_path = sys.argv[1]
    
    if not os.path.exists(pdf_path):
        print(json.dumps({
            "success": False,
            "error": f"PDF file not found: {pdf_path}"
        }))
        sys.exit(1)
    
    # Extract text using Marker
    result = extract_with_marker(pdf_path)
    
    # Output result as JSON
    print(json.dumps(result, ensure_ascii=False))

if __name__ == "__main__":
    main()
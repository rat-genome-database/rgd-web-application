<html !DOCTYPE>
<head>
    <title>Bootstrap 3 Collapsible Sidebar</title>
    <!-- Bootstrap CSS CDN -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <!-- Our Custom CSS -->
    <style>
        .wrapper {
            display: flex;
            align-items: stretch;
        }

        #sidebar {
            min-width: 250px;
            max-width: 250px;
            min-height: 100vh;
        }

        #sidebar.active {
            margin-left: -250px;
        }

        a[data-toggle="collapse"] {
            position: relative;
        }

        a[aria-expanded="false"]::before, a[aria-expanded="true"]::before {
            content: '\e259';
            display: block;
            position: absolute;
            right: 20px;
            font-family: 'Glyphicons Halflings', serif;
            font-size: 0.6em;
        }

        a[aria-expanded="true"]::before {
            content: '\e260';
        }

        @media (max-width: 768px) {
            #sidebar {
                margin-left: -250px;
            }
            #sidebar.active {
                margin-left: 0;
            }
        }

    


        body {
            font-family: 'Poppins', sans-serif;
            background: #fafafa;
        }

        p {
            font-family: 'Poppins', sans-serif;
            font-size: 1.1em;
            font-weight: 300;
            line-height: 1.7em;
            color: #999;
        }

        a, a:hover, a:focus {
            color: inherit;
            text-decoration: none;
            transition: all 0.3s;
        }

        #sidebar {
            /* don't forget to add all the previously mentioned styles here too */
            background: #7386D5;
            color: #fff;
            transition: all 0.3s;
        }

        #sidebar .sidebar-header {
            padding: 20px;
            background: #6d7fcc;
        }

        #sidebar ul.components {
            padding: 20px 0;
            border-bottom: 1px solid #47748b;
        }

        #sidebar ul p {
            color: #fff;
            padding: 10px;
        }

        #sidebar ul li a {
            padding: 10px;
            font-size: 1.1em;
            display: block;
        }
        #sidebar ul li a:hover {
            color: #7386D5;
            background: #fff;
        }

        #sidebar ul li.active > a, a[aria-expanded="true"] {
            color: #fff;
            background: #6d7fcc;
        }
        ul ul a {
            font-size: 0.9em !important;
            padding-left: 30px !important;
            background: #6d7fcc;
        }

    </style>
</head>
<body>


<!-- jQuery CDN -->
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<!-- Bootstrap Js CDN -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<script>
    $(document).ready(function () {

        $('#sidebarCollapse').on('click', function () {
            $('#sidebar').toggleClass('active');
        });

    });
</script>

<div class="wrapper">

    <!-- Sidebar -->
    <nav id="sidebar">
        <!-- Sidebar Header -->
        <div class="sidebar-header">
            <h3>Phenotype Traits</h3></div>


<!-- Sidebar Links -->
<ul class="list-unstyled components">
    <li class="active"><a href="#">Alimentary System Trait</a></li>
    <li><a href="#">Circulatory System Trait</a></li>

    <li><!-- Link with dropdown items -->
        <a href="#homeSubmenu" data-toggle="collapse" aria-expanded="false">Connective Tissue Trait</a>
        <ul class="collapse list-unstyled" id="homeSubmenu">
            <li><a href="#">Page</a></li>
            <li><a href="#">Page</a></li>
            <li><a href="#">Page</a></li>
        </ul>
    </li>
    <li><a href="#">Endocrine/Ecocrine System Trait</a></li>
    <li><a href="#">Hemolmphoid System Trait</a></li>
    <li><a href="#">Immunie System Trait</a></li>
    <li><a href="#">Integumentary System Trait</a></li>
    <li><a href="#">Muscular System Trait</a></li>
    <li><a href="#">Nervous/Sensory System Trait</a></li>
    <li><a href="#">Reproductive System Trait</a></li>
    <li><a href="#">Respiatory System Trait</a></li>
    <li><a href="#">Urinary System Trait</a></li>
</ul>
</nav>

<!-- Page Content -->
<div id="content">
    <!-- We'll fill this with dummy content -->

         <button type="button" id="sidebarCollapse" class="btn btn-info navbar-btn">
            <i class="glyphicon glyphicon-align-left"></i>
            Toggle Sidebar
        </button>
        <div>
        </div>

    </div>
</div>
</body>
</html>
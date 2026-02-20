<style>
    .sp-bar { display:flex; align-items:center; justify-content:center; gap:2px; padding:5px 10px; background:#f8f9fa; border-bottom:1px solid #e0e0e0; flex-wrap:wrap; }
    .sp-bar-label { font-family:'Source Code Pro',monospace; font-size:12px; color:#555; margin-right:8px; white-space:nowrap; }
    .sp-bar-item { position:relative; display:inline-block; }
    .sp-bar-item img { width:50px; height:50px; border:1px solid #ccc; padding:2px; border-radius:3px; display:block; transition:border-color 0.2s; }
    .sp-bar-item:hover img { border-color:#2865a3; }
    .sp-bar-overlay { position:absolute; top:0; left:0; width:100%; height:100%; background:rgba(40,101,163,0.9); display:flex; align-items:center; justify-content:center; opacity:0; transition:opacity 0.2s; border-radius:3px; text-decoration:none; }
    .sp-bar-overlay span { color:#fff; font-size:10px; font-weight:700; text-align:center; line-height:1.2; padding:2px; }
    .sp-bar-item:hover .sp-bar-overlay { opacity:1; }
    @media (max-width: 768px) {
        .sp-bar { padding: 4px 5px; gap: 1px; }
        .sp-bar-item img { width: 35px; height: 35px; }
        .sp-bar-overlay span { font-size: 8px; }
        .sp-bar-label { font-size: 10px; margin-right: 4px; }
    }
    @media (max-width: 480px) {
        .sp-bar-item img { width: 28px; height: 28px; }
        .sp-bar-overlay span { font-size: 7px; }
        .sp-bar-label { display: none; }
    }
</style>
<div class="sp-bar">
    <span class="sp-bar-label">Species Portals</span>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/ratI.png" alt="Rat"/>
        <a class="sp-bar-overlay" href="/wg/home"><span>Rat</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/humanI.png" alt="Human"/>
        <a class="sp-bar-overlay" href="/wg/species/human/"><span>Human</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/mouseI.jpg" alt="Mouse"/>
        <a class="sp-bar-overlay" href="/wg/species/mouse"><span>Mouse</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/chinchillaI.jpg" alt="Chinchilla"/>
        <a class="sp-bar-overlay" href="/wg/species/chinchilla"><span>Chinchilla</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/dogI.jpg" alt="Dog"/>
        <a class="sp-bar-overlay" href="/wg/species/dog"><span>Dog</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/squirrelI.jpg" alt="Squirrel"/>
        <a class="sp-bar-overlay" href="/wg/species/squirrel"><span>Squirrel</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/bonoboI.jpg" alt="Bonobo"/>
        <a class="sp-bar-overlay" href="/wg/species/bonobo"><span>Bonobo</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/pigI.png" alt="Pig"/>
        <a class="sp-bar-overlay" href="/wg/species/pig"><span>Pig</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/mole-ratI.png" alt="Naked Mole-rat"/>
        <a class="sp-bar-overlay" href="/wg/species/mole-rat"><span>Naked Mole-rat</span></a>
    </div>
    <div class="sp-bar-item">
        <img src="/rgdweb/common/images/species/green-monkeyI.png" alt="Green Monkey"/>
        <a class="sp-bar-overlay" href="/wg/species/green-monkey"><span>Green Monkey</span></a>
    </div>
</div>

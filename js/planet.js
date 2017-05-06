function dataLoader()
{
    this.data_count = 0;
    this.data_array = new Array();
}

function loadFile( file, loader ){
    var FileObject = new Object();
    FileObject.data  = "";
    FileObject.ready = false;
    FileObject.id    = loader.data_count;
    loader.data_array[loader.data_count] = false;
    $.ajax({
        type: "GET",
        url: file,
        dataType: "text",
        async: false
    }).done( function( msg ) {
        FileObject.data = msg;
        FileObject.ready = true;
        loader.data_array[FileObject.id] = true;
    });
    loader.data_count += 1;
    return FileObject;
}

var loader = new dataLoader();
var vertex_shader = loadFile("shaders/planet_vertex.glsl", loader).data;
var frag_shader2 = loadFile("shaders/planet_frag.glsl", loader).data;

var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.0000000001, 1000 );

var renderer = new THREE.WebGLRenderer({ antialias: true});
renderer.setSize( window.innerWidth, window.innerHeight );
document.body.appendChild( renderer.domElement );

window.addEventListener('resize', function() {
  var WIDTH = window.innerWidth,
      HEIGHT = window.innerHeight;
  renderer.setSize(WIDTH, HEIGHT);
  camera.aspect = WIDTH / HEIGHT;
  camera.updateProjectionMatrix();
});

controls = new THREE.OrbitControls(camera, renderer.domElement);

var axisHelper = new THREE.AxisHelper( 50 );
scene.add( axisHelper );

var cube_geometry = new THREE.BoxGeometry( 1, 1, 1 );
var cube_material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
var cube = new THREE.Mesh( cube_geometry, cube_material );

var sphere_wireframe = new THREE.WireframeGeometry(sphere_geometry);

function getQueryVariable(variable)
{
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable){return pair[1];}
       }
       return(false);
}

var seed = parseInt(getQueryVariable("seed"));
rotation = getQueryVariable("rotation");
shouldRotate = true;
if (rotation == "false") {
  shouldRotate = false;
}


shader_material = new THREE.ShaderMaterial({uniforms: {seed: {type: "i", value: seed}}, vertexShader: vertex_shader, fragmentShader: frag_shader2});

var sphere_geometry = new THREE.SphereGeometry( 1, 50, 50 );

var clouds = new THREE.SphereGeometry(1.01, 50, 50);
var cloud_material = new THREE.MeshPhongMaterial({
  map     : THREE.ImageUtils.loadTexture("img/earthcloudmaptrans.jpg"),
  transparent : true,
  opacity : 0.1,
})

var sphere = new THREE.Mesh( sphere_geometry, shader_material );
var cloud_mesh = new THREE.Mesh(clouds, cloud_material);
var background_geometry = new THREE.SphereGeometry(10, 64, 64);
var background_material = new THREE.MeshBasicMaterial({
  map : THREE.ImageUtils.loadTexture("img/stars.png"),
  side : THREE.BackSide,
  depthWrite : false,
})
var background = new THREE.Mesh(background_geometry, background_material);
scene.add ( background);
scene.add( cloud_mesh);
renderer.sortObjects = false;
scene.add( sphere );
camera.position.z = 3;
controls.minDistance = 1.0;
controls.zoomSpeed = 0.25;

function render() {
    requestAnimationFrame( render );
    if (shouldRotate) {sphere.rotation.y += 0.001;
        cloud_mesh.rotation.y += 0.0001;}

    renderer.render( scene, camera );
}
render();
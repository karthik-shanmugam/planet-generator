var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );




var renderer = new THREE.WebGLRenderer();
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


var light = new THREE.PointLight(0x707070, 5);
light.position.set(-100,200,100);
scene.add(light);

var light = new THREE.AmbientLight( 0x404040 ); // soft white light
scene.add( light );



var axisHelper = new THREE.AxisHelper( 50 );
scene.add( axisHelper );










var cube_geometry = new THREE.BoxGeometry( 1, 1, 1 );
var cube_material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
var cube = new THREE.Mesh( cube_geometry, cube_material );

var sphere_geometry = new THREE.SphereGeometry( 5, 50, 50 );





var sphere_wireframe = new THREE.WireframeGeometry(sphere_geometry);
var sphere_line = new THREE.LineSegments( sphere_wireframe );
sphere_line.material.depthTest = false;
sphere_line.material.opacity = 0.25;
sphere_line.material.transparent = true;

// scene.add( sphere_line );




var loader = new THREE.TextureLoader();
var colorMap = loader.load("img/earth_atmos_2048.jpg");
var specMap = loader.load("img/earth_specular_2048.jpg");
var normalMap = loader.load("img/earth_normal_2048.jpg");

var sphere_material = new THREE.MeshPhongMaterial({
  color: 0xaaaaaa,
  specular: 0x333333,
  shininess: 15,
  map: colorMap,
  specularMap: specMap,
  normalMap: normalMap
});


// var sphere_material = new THREE.MeshBasicMaterial( {map: texture} );





var sphere = new THREE.Mesh( sphere_geometry, sphere_material );




// scene.add( cube );
scene.add( sphere );


camera.position.z = 15;

function render() {
    requestAnimationFrame( render );
    // cube.rotation.x += 0.1;
    // cube.rotation.y += 0.1;

    sphere.rotation.y += 0.005;
    // sphere_line.rotation.y += 0.01;
    renderer.render( scene, camera );
}
render();
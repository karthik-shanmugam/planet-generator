var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );

var renderer = new THREE.WebGLRenderer();
renderer.setSize( window.innerWidth, window.innerHeight );
document.body.appendChild( renderer.domElement );

var cube_geometry = new THREE.BoxGeometry( 1, 1, 1 );
var cube_material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
var cube = new THREE.Mesh( cube_geometry, cube_material );

var sphere_geometry = new THREE.SphereGeometry( 5, 50, 50 );

var sphere_wireframe = new THREE.WireframeGeometry(sphere_geometry);
var sphere_line = new THREE.LineSegments( sphere_wireframe );
sphere_line.material.depthTest = false;
sphere_line.material.opacity = 0.25;
sphere_line.material.transparent = true;

scene.add( sphere_line );

var sphere_material = new THREE.MeshBasicMaterial( {color: 0xffff00} );
var sphere = new THREE.Mesh( sphere_geometry, sphere_material );




// scene.add( cube );
scene.add( sphere );


camera.position.z = 15;

function render() {
    requestAnimationFrame( render );
    cube.rotation.x += 0.1;
    cube.rotation.y += 0.1;

    sphere.rotation.y += 0.01;
    sphere_line.rotation.y += 0.01;
    renderer.render( scene, camera );
}
render();
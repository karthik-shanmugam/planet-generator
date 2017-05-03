uniform int seed;
varying vec2 vUv;
varying float disp;
varying vec3 worldPos;
varying vec3 objPos;
varying vec3 objNorm;
varying vec3 worldNorm;


// uniform vec3 cameraPosition;












//
// GLSL textureless classic 3D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-10-11
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/stegu/webgl-noise
//

vec3 mod289(vec3 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec3 fade(vec3 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}







float snoise(vec3 v)
  { 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
  }








// Classic Perlin noise
float cnoise(vec3 P)
{
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}

// Classic Perlin noise, periodic variant
float pnoise(vec3 P, vec3 rep)
{
  vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
  vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}


















// vec4 mod289(vec4 x) {
//   return x - floor(x * (1.0 / 289.0)) * 289.0; }

float mod289(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

// vec4 permute(vec4 x) {
//      return mod289(((x*34.0)+1.0)*x);
// }

float permute(float x) {
     return mod289(((x*34.0)+1.0)*x);
}

// vec4 taylorInvSqrt(vec4 r)
// {
//   return 1.79284291400159 - 0.85373472095314 * r;
// }

float taylorInvSqrt(float r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4(float j, vec4 ip)
  {
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;

  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www; 

  return p;
  }
            
// (sqrt(5) - 1)/4 = F4, used once below
#define F4 0.309016994374947451

float snoise(vec4 v)
  {
  const vec4  C = vec4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                       -0.447213595499958); // -1 + 4 * G4

// First corner
  vec4 i  = floor(v + dot(v, vec4(F4)) );
  vec4 x0 = v -   i + dot(i, C.xxxx);

// Other corners

// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  vec4 i0;
  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
//  i0.x = dot( isX, vec3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
//  i0.y += dot( isYZ.xy, vec2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  // i0 now contains the unique values 0,1,2,3 in each channel
  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  //  x0 = x0 - 0.0 + 0.0 * C.xxxx
  //  x1 = x0 - i1  + 1.0 * C.xxxx
  //  x2 = x0 - i2  + 2.0 * C.xxxx
  //  x3 = x0 - i3  + 3.0 * C.xxxx
  //  x4 = x0 - 1.0 + 4.0 * C.xxxx
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;

// Permutations
  i = mod289(i); 
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute( permute( permute( permute (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));

// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0 = grad4(j0,   ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);

// Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));

// Mix contributions from the five corners
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

  }













































// float rand(vec3 co){
//   return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
// }

float is_land(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(10.0, 0.0, 0.0);

  float l0 = 0.66 * snoise( vec4(1.0 * x,  float(seed)));
  float l1 = 0.22 * snoise( vec4(2.0 * x,  float(seed)));
  float l2 = 1.0 * 0.075 * snoise( vec4(4.0 * x,  float(seed)));
  float l3 = 1.0 * 0.055 * snoise( vec4(8.0 * x,  float(seed)));
  float disp2 = l0 + l1 + l2 + l3;
  return disp2;  
}

vec3 ocean_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(20.0, 0.0, 0.0);

  float l0 = 0.66 * snoise( 12.8 * x);
  float l1 = 0.22 * snoise( 25.6 * x);
  float l2 = 1.0 * 0.075 * snoise( 51.2 * x);
  float l3 = 1.0 * 0.055 * snoise( 102.4 * x);
  float disp2 = l0 + l1 + l2 + l3;
  return (1.0 - 0.1 * disp2) * vec3(0.0, 0.3, 0.8);
}

vec3 land_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(100.0, 0.0, 0.0);
  float dist = length(cameraPosition - worldPos);
  float l0 = dist < 100.0 ? 0.66 * snoise( vec4(5.0 * x, -float(seed))) : 0.0;
  float l1 = dist < 100.0 ? 0.22 * snoise( vec4(10.0 * x, -float(seed))) : 0.0;
  float l2 = dist < 100.0  ? 0.075 * snoise( vec4(20.0 * x, -float(seed))) : 0.0;
  float l3 = dist < 0.5   ? 0.055 * snoise( vec4(4000.0 * x, -float(seed))) : 0.0;
  float l4 = dist < 0.25   ? 0.055 * snoise( vec4(40000.0 * x, -float(seed))) : 0.0;
  float l5 = dist < 0.125   ? 0.055 * snoise( vec4(80000.0 * x, -float(seed))) : 0.0;

  float disp2 = l0 + l1 + l2 + l3 + l4 + l5;
  return (1.0 - 0.8 * disp2) * vec3(0.2, 0.7, 0.2);

//   float l0 = 0.66 * cnoise( 5.0 * x);
//   float l1 = 0.22 * cnoise( 10.0 * x);
//   float l2 = 1.0 * 0.075 * cnoise( 20.0 * x);
//   float l3 = 1.0 * 0.055 * cnoise( 4000.0 * x);
//   float l4 = 1.0 * 0.055 * cnoise( 40000.0 * x);
//   float disp2 = l0 + l1 + l2 + l3 + l4;
//   return (1.0 - disp2) * vec3(0.2, 0.7, 0.2);
}

vec3 coast_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(50.0, 0.0, 0.0);

  float l0 = 0.66 * cnoise( 5.0 * x);
  float l1 = 0.22 * cnoise( 10.0 * x);
  float l2 = 1.0 * 0.075 * cnoise( 20.0 * x);
  float l3 = 1.0 * 0.055 * cnoise( 4000.0 * x);
  float l4 = 1.0 * 0.055 * cnoise( 40000.0 * x);
  float disp2 = l0 + l1 + l2 + l3 + l4;
  return (1.0 - disp2) * vec3(0.8, 0.8, 0.0);
}

vec3 forest_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(100.0, 100.0, 0.0);

  float l0 = 0.66 * cnoise( 5.0 * x);
  float l1 = 0.22 * cnoise( 10.0 * x);
  float l2 = 1.0 * 0.075 * cnoise( 20.0 * x);
  float l3 = 1.0 * 0.055 * cnoise( 4000.0 * x);
  float l4 = 1.0 * 0.055 * cnoise( 40000.0 * x);
  float disp2 = l0 + l1 + l2 + l3 + l4;
  return (1.0 - disp2) * vec3(0.3, 0.6, 0.1);
}

vec3 taiga_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(50.0, 50.0, 0.0);

  float l0 = 0.66 * cnoise( 5.0 * x);
  float l1 = 0.22 * cnoise( 10.0 * x);
  float l2 = 1.0 * 0.075 * cnoise( 20.0 * x);
  float l3 = 1.0 * 0.055 * cnoise( 4000.0 * x);
  float l4 = 1.0 * 0.055 * cnoise( 40000.0 * x);
  float disp2 = l0 + l1 + l2 + l3 + l4;
  return (1.0 - disp2) * vec3(0.6, 0.6, 0.2);
}

vec3 mountain_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(0.0, 50.0, 50.0);

  float l0 = 0.66 * cnoise( 5.0 * x);
  float l1 = 0.22 * cnoise( 10.0 * x);
  float l2 = 1.0 * 0.075 * cnoise( 20.0 * x);
  float l3 = 1.0 * 0.055 * cnoise( 4000.0 * x);
  float l4 = 1.0 * 0.055 * cnoise( 40000.0 * x);
  float disp2 = l0 + l1 + l2 + l3 + l4;
  return (1.0 - disp2) * vec3(0.5, 0.5, 0.6);
}

vec3 mountain2_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(0.0, 7.0, 7.0);

  float l0 = 0.66 * cnoise( 5.0 * x);
  float l1 = 0.22 * cnoise( 10.0 * x);
  float l2 = 1.0 * 0.075 * cnoise( 20.0 * x);
  float l3 = 1.0 * 0.055 * cnoise( 4000.0 * x);
  float l4 = 1.0 * 0.055 * cnoise( 40000.0 * x);
  float disp2 = l0 + l1 + l2 + l3 + l4;
  return (1.0 - disp2) * vec3(0.8, 0.8, 0.9);
}

vec3 mountain3_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(3.0, 5.0, 4.0);

  float l0 = 0.66 * cnoise( 5.0 * x);
  float l1 = 0.22 * cnoise( 10.0 * x);
  float l2 = 1.0 * 0.075 * cnoise( 20.0 * x);
  float l3 = 1.0 * 0.055 * cnoise( 4000.0 * x);
  float l4 = 1.0 * 0.055 * cnoise( 40000.0 * x);
  float disp2 = l0 + l1 + l2 + l3 + l4;
  return (1.0 - disp2) * vec3(0.9, 0.9, 1.0);
}

vec3 peak_noise(vec3 x){
  // move to a new sections of perlin noise space
  x = x + vec3(7.0, 7.0, 7.0);

  float l0 = 0.66 * cnoise( 5.0 * x);
  float l1 = 0.22 * cnoise( 10.0 * x);
  float l2 = 1.0 * 0.075 * cnoise( 20.0 * x);
  float l3 = 1.0 * 0.055 * cnoise( 4000.0 * x);
  float l4 = 1.0 * 0.055 * cnoise( 40000.0 * x);
  float disp2 = l0 + l1 + l2 + l3 + l4;
  return (1.0 - disp2) * vec3(1.0, 1.0, 1.0);
}


mat4 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}
vec3 compute_normal(vec3 a, vec3 b, vec3 c)
{
  vec3 dir = cross(b-a, c-a);
  vec3 res = dir / length(dir);
  return res;
  // return (a + b + c + d) / 4.0;
}

vec3 to_sample(vec3 x, vec3 normal, float delta)
{
  vec3 c;
  if (x.y != 0.0 || x.y != 0.0) {
    c = vec3(1.0, 0.0, 0.0);
  } else {
    c = vec3(0.0, 1.0, 0.0);
  }
  mat4 rot = rotationMatrix(normal, radians(60.0));
  vec3 cur1 = normalize(cross(normal, c)) * delta;
  vec3 cur2 = (rot * vec4(cur1, 0)).xyz;
  vec3 cur3 = (rot * vec4(cur2, 0)).xyz;
  return compute_normal(cur1, cur2, cur3);
  
}






// vec3 ss_land_noise(vec x, int n) {
//   vec3 tot;
//   for (int i = 0; i < n; i++)
// }

vec3 shadePhong(vec3 color, vec3 lightPos, vec3 vertex, vec3 normal, vec3 eyePos, vec3 phongConstants)
{
    // TODO Part 7.
    // TODO Compute Phong shading here. You can choose any color you like. But make
    // TODO sure that you have noticeable specular highlights in the shading.
    // TODO Variables to use: eyePos, lightPos, normal, vertex

    vec3 l = normalize(lightPos - vertex);
    vec3 v = normalize(eyePos - vertex);
    vec3 h = (v+l)/length(v+l);
    vec3 n = normalize(normal);
    float r = length(lightPos-vertex);
    float ka = phongConstants.x;//0.3;
    float Ia = 1.0;
    float kd = phongConstants.y;//1.8;
    float ks = phongConstants.z;//0.1;
    float p = 100.0;
    float I = 50000.0;
    return color * (ka*Ia + kd*(I/(r*r))*max(0.0, dot(n, l)) + ks*(I/(r*r))*pow(max(0.0, dot(n, h)), p));
}


vec3 atmosphereShader(vec3 lightPos, vec3 vertex, vec3 normal, vec3 eyePos)
{
  float PI = 3.14159265358979323846264;
  vec3 light = lightPos - vertex;
  vec3 cameraDir = normalize(eyePos - vertex);
  
  light = normalize(light);
  
  float lightAngle = max(0.0, dot(normal, light));
  // lightAngle = 1.0;
  float viewAngle = max(0.0, dot(normal, cameraDir));
  float adjustedLightAngle = min(0.6, lightAngle) / 0.6;
  float adjustedViewAngle = min(0.65, viewAngle) / 0.65;
  float invertedViewAngle = pow(acos(viewAngle), 3.0) * 0.4;
  
  float dProd = 0.0;
  dProd += 0.5 * lightAngle;
  dProd += 0.2 * lightAngle * (invertedViewAngle - 0.1);
  dProd += invertedViewAngle * 0.5 * (max(-0.35, dot(normal, light)) + 0.35);
  dProd *= 0.7 + pow(invertedViewAngle/(PI/2.0), 2.0);
  
  dProd *= 0.6;
  return min(vec3(dProd, dProd, dProd), 0.8);//vec4 atmColor = vec4(dProd, dProd, dProd, 1.0);
  
  // vec4 texelColor = texture2D(map, vUv) * min(asin(lightAngle), 1.0);
  // gl_FragColor = texelColor + min(atmColor, 0.8);
}




























void main(void)
{
  // float l0 = 0.66 * cnoise( 0.2 * pos);
  // float l1 = 0.22 * cnoise( 0.4 * pos);
  // float l2 = 1.0 * 0.075 * cnoise( 0.8 * pos);
  // float l3 = 1.0 * 0.055 * cnoise( 1.6 * pos);
  // float disp2 = l0 + l1 + l2 + l3;
  // float c = disp2;//1.0 - 0.3 + 0.6 * disp2;
  vec3 lightPos = vec3(0.0, 0.0, 236.0);
  vec3 color;
  vec3 sample_pos = objPos;// + vec3(float(seed), float(seed), float(seed));
  vec3 land_constants = vec3(0.05, 1.4, 0.05);
  vec3 ocean_constants = vec3(0.05, 1.2, 0.8);
  float elevation = is_land(sample_pos);
  if (elevation < 0.1) {
    color = ocean_noise(sample_pos);
  } else if (elevation < 0.125) {
    color = coast_noise(sample_pos);
  } else if (elevation < 0.16) {
    color = forest_noise(sample_pos);
  } else if (elevation < 0.5) {
    color = land_noise(sample_pos);
  } else {
    color = peak_noise(sample_pos);
  }


  if (elevation < 0.1) {
    color = shadePhong(color, lightPos, worldPos, worldNorm, cameraPosition, land_constants);
  } else {
    color = shadePhong(color, lightPos, worldPos, worldNorm, cameraPosition, ocean_constants);
  }

  vec3 atmospheric = atmosphereShader(lightPos, worldPos, worldNorm, cameraPosition);

  float dist = length(cameraPosition - worldPos);
  float atmosphericStrength = 0.0;
  if (dist < 0.5) {
    atmosphericStrength = 0.0;
  } else if (dist < 2.0) {
    atmosphericStrength = (dist - 0.5) / (2.0 - 0.5);
  } else {
    atmosphericStrength = 1.0;
  }
  color += atmosphereShader(lightPos, worldPos, worldNorm, cameraPosition) * atmosphericStrength;

  

  // color /= length(cameraPosition - pos);

  // if (length(pos) > 1.0) {
  //   color = vec3(1.0, 1.0, 1.0);
  // }
  // c = c - mod(c, 0.1);
  // vec3 color = vec3(c, c, c);
  // if (c < 0.5) {
  //   color = vec3(0.0, 0.0, 0.0);
  // } else {
  //   color = vec3(1.0, 1.0, 1.0);
  // }
  // vec3 color = vec3(1.0, 1.0, 1.0) * (1.0 - 0.3 + 0.6 * disp2);
  gl_FragColor = vec4(color, 1.0);//vec4(rand(col), rand(col + vec3(1.0, 1.0, 1.0)), rand(col + vec3(2.0, 2.0, 2.0)), 1.0);
}

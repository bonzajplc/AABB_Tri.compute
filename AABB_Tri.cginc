﻿/********************************************************/

/* AABB-triangle overlap test code                      */

/* by Tomas Akenine-Möller                              */

/* Function: int triBoxOverlap(float boxcenter[3],      */

/*          float boxhalfsize[3],float triverts[3][3]); */

/* History:                                             */

/*   2001-03-05: released the code in its first version */

/*   2001-06-18: changed the order of the tests, faster */

/*                                                      */

/* Acknowledgement: Many thanks to Pierre Terdiman for  */

/* suggestions and discussions on how to optimize code. */

/* Thanks to David Hunt for finding a ">="-bug!         */

/********************************************************/

#define FINDMINMAX(x0,x1,x2,min,max)  min = max = x0; if(x1<min) min=x1; if(x1>max) max=x1; if(x2<min) min=x2; if(x2>max) max=x2;

int planeBoxOverlap(float3 normal, float3 vert, float3 maxbox)	// -NJMP-
{
    int q;

    float3 vmin, vmax;
    float v;

    v = vert.x;
    if (normal.x > 0.0f)
    {
        vmin.x = -maxbox.x - v; // -NJMP-
        vmax.x = maxbox.x - v; // -NJMP-
    }
    else
    {
        vmin.x = maxbox.x - v; // -NJMP-
        vmax.x = -maxbox.x - v; // -NJMP-
    }

    v = vert.y;
    if (normal.y > 0.0f)
    {
        vmin.y = -maxbox.y - v; // -NJMP-
        vmax.y = maxbox.y - v; // -NJMP-
    }
    else
    {
        vmin.y = maxbox.y - v; // -NJMP-
        vmax.y = -maxbox.y - v; // -NJMP-
    }

    v = vert.z;
    if (normal.z > 0.0f)
    {
        vmin.z = -maxbox.z - v; // -NJMP-
        vmax.z = maxbox.z - v; // -NJMP-
    }
    else
    {
        vmin.z = maxbox.z - v; // -NJMP-
        vmax.z = -maxbox.z - v; // -NJMP-
    }

    if (dot(normal, vmin) > 0.0f)
        return 0; // -NJMP-

    if (dot(normal, vmax) >= 0.0f)
        return 1; // -NJMP-

    return 0;
}

int triBoxOverlap(float3 boxcenter, float3 boxhalfsize, float3 V0, float3 V1, float3 V2)
{
  /*    use separating axis theorem to test overlap between triangle and box */

  /*    need to test for overlap in these directions: */

  /*    1) the {x,y,z}-directions (actually, since we use the AABB of the triangle */

  /*       we do not even need to test these) */

  /*    2) normal of the triangle */

  /*    3) crossproduct(edge from tri, {x,y,z}-directin) */

  /*       this gives 3x3=9 more tests */

    float3 v0, v1, v2;

//   float axis[3];

    float min, max, p0, p1, p2, rad; // -NJMP- "d" local variable removed

    float3 normal, e0, e1, e2, fe;

    float a, b, fa, fb;

   /* This is the fastest branch on Sun */

   /* move everything so that the boxcenter is in (0,0,0) */

    v0 = V0 - boxcenter;
    v1 = V1 - boxcenter;
    v2 = V2 - boxcenter;

   /* compute triangle edges */

    e0 = v1 - v0; /* tri edge 0 */
    e1 = v2 - v1; /* tri edge 1 */
    e2 = v0 - v2; /* tri edge 2 */

   /* Bullet 3:  */

   /*  test the 9 tests first (this was faster) */

    fe = abs(e0);

//    AXISTEST_X01(e0.z, e0.y, fe.z, fe.y);
    a = e0.z;
    b = e0.y;
    fa = fe.z;
    fb = fe.y;

    p0 = a * v0.y - b * v0.z;
    p2 = a * v2.y - b * v2.z;

    if (p0 < p2)
    {
        min = p0;
        max = p2;
    }
    else
    {
        min = p2;
        max = p0;
    }

    rad = fa * boxhalfsize.y + fb * boxhalfsize.z;

    if (min > rad || max < -rad)
        return 0;

//   AXISTEST_Y02(e0.z, e0.x, fe.z, fe.x);
    a = e0.z;
    b = e0.x;
    fa = fe.z;
    fb = fe.x;

    p0 = -a * v0.x + b * v0.z;
    p2 = -a * v2.x + b * v2.z;

    if (p0 < p2)
    {
        min = p0;
        max = p2;
    }
    else
    {
        min = p2;
        max = p0;
    }

    rad = fa * boxhalfsize.x + fb * boxhalfsize.z;

    if (min > rad || max < -rad)
        return 0;

//   AXISTEST_Z12(e0.y, e0.x, fe.y, fe.x);
    a = e0.y;
    b = e0.x;
    fa = fe.y;
    fb = fe.x;

    p1 = a * v1.x - b * v1.y;
    p2 = a * v2.x - b * v2.y;

    if (p2 < p1)
    {
        min = p2;
        max = p1;
    }
    else
    {
        min = p1;
        max = p2;
    }

    rad = fa * boxhalfsize.x + fb * boxhalfsize.y;

    if (min > rad || max < -rad)
        return 0;

    fe = abs(e1);

//    AXISTEST_X01(e1.z, e1.y, fe.z, fe.y);
    a = e1.z;
    b = e1.y;
    fa = fe.z;
    fb = fe.y;

    p0 = a * v0.y - b * v0.z;
    p2 = a * v2.y - b * v2.z;

    if (p0 < p2)
    {
        min = p0;
        max = p2;
    }
    else
    {
        min = p2;
        max = p0;
    }

    rad = fa * boxhalfsize.y + fb * boxhalfsize.z;

    if (min > rad || max < -rad)
        return 0;

//   AXISTEST_Y02(e1.z, e1.x, fe.z, fe.x);
    a = e1.z;
    b = e1.x;
    fa = fe.z;
    fb = fe.x;

    p0 = -a * v0.x + b * v0.z;
    p2 = -a * v2.x + b * v2.z;

    if (p0 < p2)
    {
        min = p0;
        max = p2;
    }
    else
    {
        min = p2;
        max = p0;
    }

    rad = fa * boxhalfsize.x + fb * boxhalfsize.z;

    if (min > rad || max < -rad)
        return 0;

//   AXISTEST_Z0(e1.y, e1.x, fe.y, fe.x);
    a = e1.y;
    b = e1.x;
    fa = fe.y;
    fb = fe.x;

    p0 = a * v0.x - b * v0.y;
    p1 = a * v1.x - b * v1.y;

    if (p0 < p1)
    {
        min = p0;
        max = p1;
    }
    else
    {
        min = p1;
        max = p0;
    }

    rad = fa * boxhalfsize.x + fb * boxhalfsize.y;

    if (min > rad || max < -rad)
        return 0;

    fe = abs(e2);

//   AXISTEST_X2(e2.z, e2.y, fe.z, fe.y);
    a = e2.z;
    b = e2.y;
    fa = fe.z;
    fb = fe.y;

    p0 = a * v0.y - b * v0.z;
    p1 = a * v1.y - b * v1.z;

    if (p0 < p1)
    {
        min = p0;
        max = p1;
    }
    else
    {
        min = p1;
        max = p0;
    }

    rad = fa * boxhalfsize.y + fb * boxhalfsize.z;

    if (min > rad || max < -rad)
        return 0;

//   AXISTEST_Y1(e2.z, e2.x, fe.z, fe.x);
    a = e2.z;
    b = e2.x;
    fa = fe.z;
    fb = fe.x;

    p0 = -a * v0.x + b * v0.z;
    p1 = -a * v1.x + b * v1.z;

    if (p0 < p1)
    {
        min = p0;
        max = p1;
    }
    else
    {
        min = p1;
        max = p0;
    }

    rad = fa * boxhalfsize.x + fb * boxhalfsize.z;

    if (min > rad || max < -rad)
        return 0;

//   AXISTEST_Z12(e2.y, e2.x, fe.y, fe.x);
    a = e2.y;
    b = e2.x;
    fa = fe.y;
    fb = fe.x;

    p1 = a * v1.x - b * v1.y;
    p2 = a * v2.x - b * v2.y;

    if (p2 < p1)
    {
        min = p2;
        max = p1;
    }
    else
    {
        min = p1;
        max = p2;
    }

    rad = fa * boxhalfsize.x + fb * boxhalfsize.y;

    if (min > rad || max < -rad)
        return 0;

    /* Bullet 1: */
    /* first test overlap in the {x,y,z}-directions */
    /* find min, max of the triangle each direction, and test for overlap in */
    /* that direction -- this is equivalent to testing a minimal AABB around */
    /* the triangle against the AABB */

    /* test in X-direction */

    FINDMINMAX(v0.x,v1.x,v2.x,min,max);

    if (min > boxhalfsize.x || max < -boxhalfsize.x)
        return 0;

    /* test in Y-direction */

    FINDMINMAX(v0.y,v1.y,v2.y,min,max);

    if (min > boxhalfsize.y || max < -boxhalfsize.y)
        return 0;

    /* test in Z-direction */

    FINDMINMAX(v0.z,v1.z,v2.z,min,max);

    if (min > boxhalfsize.z || max < -boxhalfsize.z)
        return 0;

   /* Bullet 2: */
   /*  test if the box intersects the plane of the triangle */
   /*  compute plane equation of triangle: normal*x+d=0 */

    normal = cross(e0, e1);

   // -NJMP- (line removed here)
    if (!planeBoxOverlap(normal, v0, boxhalfsize))
        return 0; // -NJMP-

    return 1; /* box and triangle overlaps */
}

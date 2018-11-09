using Images
using PyPlot
using Test
using LinearAlgebra
using FileIO

# Transform from Cartesian to homogeneous coordinates
function cart2hom(points::Array{Float64,2})
  points_hom = vcat(points, ones(1, size(points)[2]))


  return points_hom::Array{Float64,2}
end


# Transform from homogeneous to Cartesian coordinates
function hom2cart(points::Array{Float64,2})
  points_cart = Array{Float64, 2}(undef,size(points)[1]-1,size(points)[2])

  for i = 1:size(points)[2]
    points_cart[:,i] = points[1:size(points)[1]-1,i]/points[size(points)[1],i]
  end

  return points_cart::Array{Float64,2}
end


# Translation by v
function gettranslation(v::Array{Float64,1})
  T=Matrix{Float64}(I, 4, 4)


  T[1,4] = v[1]
  T[2,4] = v[2]
  T[3,4] = v[3]
  return T::Array{Float64,2}
end

# Rotation of d degrees around x axis
function getxrotation(d::Int)
  a_angle = d/180 * pi
  Rx = zeros(3,3)
  Rx[1,1] = 1
  Rx[2,2] = cos(a_angle)
  Rx[2,3] = -sin(a_angle)
  Rx[3,2] = sin(a_angle)
  Rx[3,3] = cos(a_angle)
  return Rx::Array{Float64,2}
end

# Rotation of d degrees around y axis
function getyrotation(d::Int)
  a_angle = d/180 * pi
  Ry = zeros(3,3)
  Ry[1,1] = cos(a_angle)
  Ry[2,2] = 1
  Ry[1,3] = sin(a_angle)
  Ry[3,1] = -sin(a_angle)
  Ry[3,3] = cos(a_angle)
  return Ry::Array{Float64,2}
end

# Rotation of d degrees around z axis
function getzrotation(d::Int)
  a_angle = d/180 * pi
  Rz = zeros(3,3)
  Rz[1,1] = cos(a_angle)
  Rz[2,2] = cos(a_angle)
  Rz[1,2] = -sin(a_angle)
  Rz[2,1] = sin(a_angle)
  Rz[3,3] = 1
  return Rz::Array{Float64,2}
end


# Central projection matrix (including camera intrinsics)
function getcentralprojection(principal::Array{Int,1}, focal::Int)
  K = Matrix{Float64}(I,3,3)
  K[1,1] = convert(Float64, focal)
  K[2,2] = convert(Float64, focal)
  K[1,3] = convert(Float64, principal[1])
  K[2,3] = convert(Float64, principal[2])
  #temp1 = hcat(Matrix{Int}(I,3,3), zeros(3,1))
  K = hcat(K, zeros(3,1))
  return K::Array{Float64,2}
end


# Return full projection matrix P and full model transformation matrix M
function getfullprojection(T::Array{Float64,2},Rx::Array{Float64,2},Ry::Array{Float64,2},Rz::Array{Float64,2},V::Array{Float64,2})
  R = Rz * Rx * Ry
  R = hcat(R, zeros(3,1))
  R = vcat(R, zeros(1,4))
  R[4,4] = 1
  M = R * T
  P = V * M
  #M = vcat(M, zeros(1, size(M)[2]))
  #M[size(M)[1],size(M)[2]] = 1
  return P::Array{Float64,2},M::Array{Float64,2}
end



# Load 2D points
function loadpoints()
  points = load("obj2d.jld2", "x")

  return points::Array{Float64,2}
end


# Load z-coordinates
function loadz()
  z = load("zs.jld2", "Z")
  return z::Array{Float64,2}
end


# Invert just the central projection P of 2d points *P2d* with z-coordinates *z*
function invertprojection(P::Array{Float64,2}, P2d::Array{Float64,2}, z::Array{Float64,2})
  P2d = vcat(P2d, z)
  P3d = P\P2d
  P3d[4,:] =ones(1, size(P3d)[2])


  return P3d::Array{Float64,2}
end

# Invert just the model transformation of the 3D points *P3d*
function inverttransformation(A::Array{Float64,2}, P3d::Array{Float64,2})

  X = A\P3d


  return X::Array{Float64,2}
end


# Plot 2D points
function displaypoints2d(points::Array{Float64,2})
  PyPlot.plot(points[1,:], points[2,:])
  return gcf()::Figure
end

# Plot 3D points
function displaypoints3d(points::Array{Float64,2})
  points_x = points[1,:]
  points_y = points[2,:]
  points_z = points[3,:]
  PyPlot.scatter3D(points_x, points_y, points_z)
  return gcf()::Figure
end

# Apply full projection matrix *C* to 3D points *X*
function projectpoints(P::Array{Float64,2}, X::Array{Float64,2})
  temp = vcat(X, ones(1, size(X)[2]))
  P3d = Array{Float64, 2}(undef, 3, size(temp)[2])
  for i = 1 : size(temp)[2]
    P3d[:,i] = P*temp[:,i]
  end
  P2d = P3d[1:2, :]
  #P2d=hom2cart(P2d)
  return P2d::Array{Float64,2}
end



#= Problem 2
Projective Transformation =#

function problem3()
  # parameters
  t               = [6.7; -10; 4.2]
  principal_point = [9; -7]
  focal_length    = 8

  # model transformations
  T = gettranslation(t)
  Ry = getyrotation(-45)
  Rx = getxrotation(120)
  Rz = getzrotation(-10)

  # central projection including camera intrinsics
  K = getcentralprojection(principal_point,focal_length)

  # full projection and model matrix
  P,M = getfullprojection(T,Rx,Ry,Rz,K)

  # load data and plot it
  points = loadpoints()
  displaypoints2d(points)

  # reconstruct 3d scene
  z = loadz()
  Xt = invertprojection(K,points,z)
  Xh = inverttransformation(M,Xt)

  worldpoints = hom2cart(Xh)
  displaypoints3d(worldpoints)

  # reproject points
  points2 = projectpoints(P,worldpoints)
  displaypoints2d(points2)

  @test points ≈ points2
  return
end


#why it is necessary to provide z-coordinates?
# From the perspective of the matrix calculation, we need the z-coordinates to
#calculates the x and y-coordinates of Xi.
# From the perspective of geometrry, our camera center is not at the principal axis,
#so we need z-coordinates to calculates the offset.
#Are the Rotations commutative?
#No, i previously used the wrong order, that results to a wrong plot. Because the
#multiplications of matrix are not commutative. 

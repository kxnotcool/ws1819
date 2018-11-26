using Images
using LinearAlgebra
using PyPlot
using Printf
using Statistics

# Load images from the yale_faces directory and return a MxN data matrix,
# where M is the number of pixels per face image and N is the number of images.
# Also return the dimensions of a single face image and the number of all face images
function loadfaces()
  #get face directory paths
  oripath = "assignment2_data_v1/yale_faces/"
  directorys = filter(x -> occursin(r"yale", x), readdir(oripath))
  imgsample = imread(oripath * directorys[1]* "/01.pgm", "pgm")
  facedim = Array{Int}(undef, 2)
  facedim[1] = size(imgsample)[1]
  facedim[2] = size(imgsample)[2]
  data = Array{Float64, 2}(undef, sizeof(imgsample), 1)

  for i = 1:length(directorys)
    path = oripath * directorys[i]
    imagess = filter(x -> occursin(r".pgm", x), readdir(path))

    for j = 1:length(imagess)
      pathtoimg = path * "/" * imagess[j]
      img = convert(Array{Float64, 2}, imread(pathtoimg))
      imginrow = img[1, :]
      for h = 2:length(img[:, 1])
        imginrow = vcat(imginrow, img[h, :])
      end
      if (i == 1 && j==1)
        data[:,1] = imginrow
      else
        data = hcat(data, imginrow)
      end
    end

  end
  #load pgm
  n = size(data)[2]

  return data::Array{Float64,2},facedim::Array{Int},n::Int
end

# Apply principal component analysis on the data matrix.
# Return the eigenvectors of covariance matrix of the data, the corresponding eigenvalues,
# the one-dimensional mean data matrix and a cumulated variance vector in increasing order.
function computepca(data::Array{Float64,2})
  N = size(data)[2]
  M = size(data)[1]
  mup = sum(data, dims=2)./N
  X = data.- mup
  usv = svd(X)
  U = usv.U
  lambda = usv.S.*usv.S./length(usv.S)
  mu = mup




  cumvar = Array{Float64, 1}(undef, N)
  cumvar[1] = lambda[1]

  for i = 2:N
    cumvar[i] = cumvar[i - 1] + lambda[i]

  end

  return U::Array{Float64,2},lambda::Array{Float64,1},mu::Array{Float64,2},cumvar::Array{Float64,1}
end

# Plot the cumulative variance of the principal components
function plotcumvar(cumvar::Array{Float64,1})
  figure()
  plot(cumvar)
  gcf()
  return nothing::Nothing
end


# Compute required number of components to account for (at least) 75/99% of the variance
function computecomponents(cumvar::Array{Float64,1})
  N = length(cumvar)
  n75 = 0
  n99 = 0
  for i = 1:N
    if(cumvar[i]/cumvar[N] >= 0.75)
      n75 = i
      break
    end
  end
  for i = n75:N
    if(cumvar[i]/cumvar[N] >= 0.99)
      n99 = i
      break
    end
  end
  return n75::Int,n99::Int
end


# Display the mean face and the first 10 Eigenfaces in a single figure
function showeigenfaces(U::Array{Float64,2},mu::Array{Float64,2},facedim::Array{Int})
  Uset = zeros(Float64, size(U)[2], facedim[1], facedim[2])
  mu1 = zeros(Float64, facedim[1], facedim[2])
  for i = 0:facedim[1]-1
    j = i * 84 + 1
    mu1[i+1,:] = mu[j:j+facedim[2]-1]


  end
  for i = 1:size(U)[2]
    j = 1
    for h = 1:facedim[1]
      Uset[i, h, :] = U[j:j+facedim[2]-1, i]
      j = h * facedim[2] + 1
    end
  end
  figure()

  subplot(261)
  imshow(mu1, "gray")
  axis("off")
  subplot(262)
  imshow(Uset[1,:,:], "gray")
  axis("off")
  subplot(263)
  imshow(Uset[2,:,:], "gray")
  axis("off")
  subplot(264)
  imshow(Uset[3,:,:], "gray")
  axis("off")
  subplot(265)
  imshow(Uset[4,:,:], "gray")
  axis("off")
  subplot(266)
  imshow(Uset[5,:,:], "gray")
  axis("off")
  subplot(267)
  imshow(Uset[6,:,:], "gray")
  axis("off")
  subplot(268)
  imshow(Uset[7,:,:], "gray")
  axis("off")
  subplot(269)
  imshow(Uset[8,:,:], "gray")
  axis("off")
  subplot(2,6,10)
  imshow(Uset[9,:,:], "gray")
  axis("off")
  subplot(2,6,11)
  imshow(Uset[10,:,:], "gray")
  axis("off")
  gcf()
  return nothing::Nothing
end


# Fetch a single face with given index out of the data matrix
function takeface(data::Array{Float64,2},facedim::Array{Int},n::Int)
  temp = data[:, n]
  face = zeros(Float64, facedim[1], facedim[2])

  for i = 0:facedim[1] - 1
    j = i * facedim[2] + 1
    face[i + 1,:] = temp[j : j + facedim[2] - 1]
  end
  return face::Array{Float64,2}
end


# Project a given face into the low-dimensional space with a given number of principal
# components and reconstruct it afterwards
function computereconstruction(faceim::Array{Float64,2},U::Array{Float64,2},mu::Array{Float64,2},n::Int)

  facedim = [size(faceim)[1], size(faceim)[2]]
  mu1 = zeros(Float64, facedim[1], facedim[2])
  for i = 0:facedim[1]-1
    j = i * 84 + 1
    mu1[i+1,:] = mu[j:j+facedim[2]-1]
  end
  translatedFace = faceim - mu1
  choosedEigenVectors = U[:,1:n]


  translatedFaceincol = translatedFace[1, :]

  for i = 2:size(mu1)[1]
    translatedFaceincol = vcat(translatedFaceincol, translatedFace[i,:])

  end

  weights = transpose(translatedFaceincol) * choosedEigenVectors# - transpose(muIncol) * choosedEigenVectors
  newFace = zeros(Float64, size(choosedEigenVectors)[1], size(choosedEigenVectors)[2])
  for i = 1:n
    newFace[:,i] = choosedEigenVectors[:,i].*weights[i]
  end
  newFace = sum(newFace,dims=2)
  recon = zeros(Float64, size(mu1)[1], size(mu1)[2])
  for i = 0:size(mu1)[1] - 1
    j = i * size(mu1)[2] + 1
    recon[i + 1, :] = newFace[j : j + size(mu1)[2] - 1]
  end
  recon = recon + mu1
  return recon::Array{Float64,2}
end

# Display all reconstructed faces in a single figure
function showreconstructedfaces(faceim, f5, f15, f50, f150)
  figure()
  subplot(2,3,1)
  imshow(faceim, "gray"),axis("off")
  subplot(2,3,2)
  imshow(f5, "gray"),axis("off")
  subplot(2,3,3)
  imshow(f15, "gray"),axis("off")
  subplot(2,3,4)
  imshow(f50, "gray"),axis("off")
  subplot(2,3,5)
  imshow(f150, "gray"),axis("off")
  gcf()
  return nothing::Nothing
end

# Problem 2: Eigenfaces

function problem2()
  # load data
  data,facedim,N = loadfaces()

  # compute PCA
  U,lambda,mu,cumvar = computepca(data)

  # plot cumulative variance
  plotcumvar(cumvar)

  # compute necessary components for 75% / 99% variance coverage
  n75,n99 = computecomponents(cumvar)
  println(@sprintf("Necssary components for 75%% variance coverage: %i", n75))
  println(@sprintf("Necssary components for 99%% variance coverage: %i", n99))

  # plot mean face and first 10 Eigenfaces
  showeigenfaces(U,mu,facedim)

  # get a random face
  faceim = takeface(data,facedim,rand(1:N))

  # reconstruct the face with 5, 15, 50, 150 principal components
  f5 = computereconstruction(faceim,U,mu,5)
  f15 = computereconstruction(faceim,U,mu,15)
  f50 = computereconstruction(faceim,U,mu,50)
  f150 = computereconstruction(faceim,U,mu,150)

  # display the reconstructed faces
  showreconstructedfaces(faceim, f5, f15, f50, f150)

  return
end

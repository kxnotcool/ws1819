using Images
using PyPlot


# Create a gaussian filter
function makegaussianfilter(size::Array{Int,2},sigma::Float64)
  f = ones(size[1, 1], size[1, 2])
  xcenter = div(size[1, 1], 2) + 1
  ycenter = div(size[1, 2], 2) + 1
  sumf = 0

  for i = 1 : size[1, 1]
    x1 = (i - xcenter) ^ 2
    for j = 1 : size[1, 2]
      y1 = (j - ycenter) ^ 2
      f[i, j] = 1 / (2 * pi * sigma ^ 2) * exp(- (x1 + y1) / (2 * sigma ^ 2))
      sumf += f[i, j]
    end
  end
  cof = 1 / sumf
  f = map(x -> cof * x, f)
  return f::Array{Float64,2}
end

# Create a binomial filter
function makebinomialfilter(size::Array{Int,2})
  f = ones(size[1, 1], size[1, 2])
  sumx = 0
  sumy = 0
  # for x size[1, 1] = N + 1 weights, set sizex = N, so does y
  sizex = size[1, 1] - 1
  sizey = size[1, 2] - 1

  for i = 1 : size[1, 1]
    sumx += binomial(sizex, i - 1)
  end

  for i = 1 : size[1, 2]
    sumy += binomial(sizey, i - 1)
  end

  for i = 1 : size[1, 1]
    for j = 1 : size[1, 2]
      f[i, j] = binomial(sizex, i - 1) / sumx * binomial(sizey, j - 1) / sumy
    end
  end
  return f::Array{Float64,2}
end

# Downsample an image by a factor of 2
function downsample2(A::Array{Float64,2})
  sizex_A = size(A, 1)
  sizey_A = size(A, 2)

# resizes both dimensions to half the size, for example 4 -> 2, 5 -> 3
  sizex_D = sizex_A - div(sizex_A, 2)
  sizey_D = sizey_A - div(sizey_A, 2)
  D = zeros(sizex_D, sizey_D)

  for i = 1 : sizex_D
    for j = 1 : sizey_D
      D[i, j] = A[i * 2 - 1, j * 2 - 1]
    end
  end
  return D::Array{Float64,2}
end

# Upsample an image by a factor of 2
function upsample2(A::Array{Float64,2},fsize::Array{Int,2})
  sizexx_A = size(A, 1)
  sizeyy_A = size(A, 2)

  # size x of U is 2 * sizexx_A - 1, so does size y
  sizex_U = sizexx_A * 2
  sizey_U = sizeyy_A * 2
  U = ones(sizex_U, sizey_U)

  for i = 1 : sizexx_A
    for j = 1 : sizeyy_A
      U[2 * i - 1, 2 * j - 1] = A[i, j]
      U[2 * i, 2 * j] = 0.0
    end
  end

  # binomial filter
  bfilter = makebinomialfilter(fsize)

  U = imfilter(U, bfilter, "symmetric")

  #scale factor of 4
  for i = 1 : sizex_U
    for j = 1 : sizey_U
      U[i, j] = U[i, j] * 4
    end
  end
  return U::Array{Float64,2}
end

# Build a gaussian pyramid from an image.
# The output array should contain the pyramid levels in decreasing sizes.
function makegaussianpyramid(im::Array{Float32,2},nlevels::Int,fsize::Array{Int,2},sigma::Float64)
  G = Array{Array{Float64, 2}, 1}(undef,nlevels + 1)
  gaufilter = makegaussianfilter(fsize, sigma)

  G[1] = convert(Array{Float64,2}, im)
  for i = 1 : nlevels
    G[i + 1] = imfilter(G[i], gaufilter, "symmetric")
    G[i + 1] = downsample2(G[i + 1])
  end

  return G::Array{Array{Float64,2},1}
end

# Display a given image pyramid (laplacian or gaussian)
function displaypyramid(P::Array{Array{Float64,2},1})
  figure()
  sizex_G = size(P[1], 1)
  sizey_G = size(P[1], 2)
  startx_G = 1
  starty_G = 1
  endy_G = sizey_G
  G = Array{Float64, 2}(undef, sizex_G, 2 * sizey_G)

  for i = 1 : size(P, 1)
    G[1 : sizex_G, starty_G : endy_G] = P[i]
    sizex_G = sizex_G - div(sizex_G, 2)
    starty_G = starty_G + sizey_G
    sizey_G = sizey_G - div(sizey_G, 2)
    endy_G = endy_G + sizey_G
  end
  imshow(G,"gray",interpolation="none")
  axis("off")
  gcf()
end

# Build a laplacian pyramid from a gaussian pyramid.
# The output array should contain the pyramid levels in decreasing sizes.
function makelaplacianpyramid(G::Array{Array{Float64,2},1},nlevels::Int,fsize::Array{Int,2})
  L = Array{Array{Float64,2},1}(undef, nlevels + 1)

  for i = 1 : nlevels
    L[i] = G[i] - upsample2(G[i + 1], fsize)
  end
  L[nlevels + 1] = G[nlevels + 1]
  return L::Array{Array{Float64,2},1}
end

# Amplify frequencies of the first two layers of the laplacian pyramid
function amplifyhighfreq2(L::Array{Array{Float64,2},1})
  A = L
  sharp = 1.2
  A[1] = A[1] * sharp
  A[2] = A[2] * sharp
  return A::Array{Array{Float64,2},1}
end

# Reconstruct an image from the laplacian pyramid
function reconstructlaplacianpyramid(L::Array{Array{Float64,2},1},fsize::Array{Int,2})
  im = L[size(L, 1)]

  for i = 1 : size(L, 1) - 1
    im = L[size(L, 1) - i] + upsample2(im, fsize)
  end

  return im::Array{Float64,2}
end


# Problem 1: Image Pyramids and Image Sharpening

function problem1()
  # parameters
  fsize = [5 5]
  sigma = 1.4
  nlevels = 6

  # load image
  im = PyPlot.imread("assignment2_data_v1/a2p1.png")

  # create gaussian pyramid
  G = makegaussianpyramid(im,nlevels,fsize,sigma)

  # display gaussianpyramid
  displaypyramid(G)
  title("Gaussian Pyramid")

  # create laplacian pyramid
  L = makelaplacianpyramid(G,nlevels,fsize)

  # dispaly laplacian pyramid
  displaypyramid(L)
  title("Laplacian Pyramid")

  # amplify finest 2 subands
  L_amp = amplifyhighfreq2(L)

  # reconstruct image from laplacian pyramid
  im_rec = reconstructlaplacianpyramid(L_amp,fsize)

  # display original and reconstructed image
  figure()
  subplot(131)
  imshow(im,"gray",interpolation="none")
  axis("off")
  title("Original Image")
  subplot(132)
  imshow(im_rec,"gray",interpolation="none")
  axis("off")
  title("Reconstructed Image")
  subplot(133)
  imshow(im-im_rec,"gray",interpolation="none")
  axis("off")
  title("Difference")
  gcf()

  return
end

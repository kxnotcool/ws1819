using Images
using PyPlot

# Create 3x3 derivative filters in x and y direction
function createfilters()
  fx = ones(3,3)
  fy = ones(3,3)
  fx_unit = Array{Float64,2}(undef, 1,3)
  g_unit = Array{Float64,2}(undef, 3,1)
  fx_unit[1,1] = 1/2
  fx_unit[1,2] = 0
  fx_unit[1,3] = -1/2

  Gsy1 = 1/sqrt(2*pi)/0.9 * exp(-1/2/0.9^2)
  Gsy0 = 1/sqrt(2*pi)/0.9
  g_unit[1,1] = Gsy1
  g_unit[2,1] = Gsy0
  g_unit[3,1] = Gsy1
  fx = g_unit * fx_unit

  fy = fx_unit' * g_unit'   #normalization?


  return fx::Array{Float64,2}, fy::Array{Float64,2}
end

# Apply derivate filters to an image and return the derivative images
function filterimage(I::Array{Float32,2},fx::Array{Float64,2},fy::Array{Float64,2})
  Ix = imfilter(I, fx)
  Iy = imfilter(I, fy)


  return Ix::Array{Float64,2},Iy::Array{Float64,2}
end


# Apply thresholding on the gradient magnitudes to detect edges
function detectedges(Ix::Array{Float64,2},Iy::Array{Float64,2}, thr::Float64)
  Ix_s = broadcast(*, Ix,Ix)
  Iy_s = broadcast(*, Iy,Iy)
  edges = broadcast(sqrt, Ix_s + Iy_s)
  for i = 1 : size(edges)[1]
    for j = 1 : size(edges)[2]
      if edges[i,j] < thr

        edges[i,j] = 0
      end
    end
  end

  return edges::Array{Float64,2}
end


# Apply non-maximum-suppression
function nonmaxsupp(edges::Array{Float64,2},Ix::Array{Float64,2},Iy::Array{Float64,2})
  row_size = size(Ix)[1]
  col_size = size(Ix)[2]
  Ix_m = broadcast(sqrt, Ix.*Ix)
  Iy_m = broadcast(sqrt, Iy.*Iy)

  Iy_mp = vcat(zeros(1, col_size), Iy_m)
  Iy_mp = vcat(Iy_mp, zeros(1, col_size))
  Iy_mp = hcat(zeros(row_size + 2, 1), Iy_mp)
  Iy_mp = hcat(Iy_mp, zeros(row_size + 2, 1))

  Ix_mp = vcat(zeros(1, col_size), Ix_m)
  Ix_mp = vcat(Ix_mp, zeros(1, col_size))
  Ix_mp = hcat(zeros(row_size + 2, 1), Ix_mp)
  Ix_mp = hcat(Ix_mp, zeros(row_size + 2, 1))

  edges_p = vcat(zeros(1, col_size), edges)
  edges_p = vcat(edges_p, zeros(1, col_size))
  edges_p = hcat(zeros(row_size + 2, 1), edges_p)
  edges_p = hcat(edges_p, zeros(row_size + 2, 1))

  for i = 2 : size(edges_p)[1] - 1
    for j =  2 : size(edges_p)[2] - 1
      if edges_p[i,j] == 0
        continue
      end

      if abs(edges_p[i-1,j] - edges_p[i+1,j]) <= abs(edges_p[i,j-1] - edges_p[i,j+1])
        if Ix_mp[i-1,j] > Ix_mp[i,j] || Ix_mp[i+1,j] > Ix_mp[i,j]
          edges[i-1,j-1] = 0
        end
      else
        if Iy_mp[i,j-1] > Iy_mp[i,j] || Iy_mp[i,j+1] > Iy_mp[i,j]
          edges[i-1,j-1] = 0
        end
      end

    end
  end

  return edges::Array{Float64,2}
end


#= Problem 4
Image Filtering and Edge Detection =#

function problem4()

  # load image
  img = PyPlot.imread("a1p4.png")

  # create filters
  fx, fy = createfilters()

  # filter image
  imgx, imgy = filterimage(img, fx, fy)

  # show filter results
  figure()
  subplot(121)
  imshow(imgx, "gray", interpolation="none")
  title("x derivative")
  axis("off")
  subplot(122)
  imshow(imgy, "gray", interpolation="none")
  title("y derivative")
  axis("off")
  gcf()

  # show gradient magnitude
  figure()
  imshow(sqrt.(imgx.^2 + imgy.^2),"gray", interpolation="none")
  axis("off")
  title("Derivative magnitude")
  gcf()

  # threshold derivative
  threshold = 18. / 255.
  edges = detectedges(imgx,imgy,threshold)
  figure()
  imshow(edges.>0, "gray", interpolation="none")
  axis("off")
  title("Binary edges")
  gcf()

  # non maximum suppression
  edges2 = nonmaxsupp(edges,imgx,imgy)
  figure()
  imshow(edges2,"gray", interpolation="none")
  axis("off")
  title("Non-maximum suppression")
  gcf()
  return
end
# f = (1,2,3)   h = (10,20,30)
#     (4,5,6)       (40,50,60)
#     (7,8,9)       (70,80,90)

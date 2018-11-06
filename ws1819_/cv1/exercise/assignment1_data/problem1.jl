using PyPlot
using FileIO
using Images
using JLD2

# load and return the given image
function loadimage()
  imgo = load("a1p1.png")
  temp = channelview(convert(Array{RGB{Float32}},imgo))
  img = convert(Array{Float32,3},temp)
  return img::Array{Float32,3}

end

# save the image as a .jld2 file
function savefile(img::Array{Float32,3})
  save("img.jld2","img",img)
end

# load and return the .jld2 file
function loadfile()
  img = load("img.jld2", "img")
  return img::Array{Float32,3}
end

# create and return a horizontally mirrored image
function mirrorhorizontal(img::Array{Float32,3})
  imgSize = size(img)
  mirrored = Array{Float32,3}(undef, imgSize[1], imgSize[2], imgSize[3])
  for i = 1:450
      mirrored[:,:,i] = img[:,:,451-i]
  end
  return mirrored::Array{Float32,3}
end

# display the normal and the mirrored image in one plot
function showimages(img1::Array{Float32,3}, img2::Array{Float32,3})
  imgSize1=size(img1)
  imgSize2=size(img2)
  imgshow1 = Array{Float32,3}(undef, imgSize1[2], imgSize1[3], 3)
  imgshow2 = Array{Float32,3}(undef, imgSize2[2], imgSize2[3], 3)
  for i=1:imgSize1[2]
    for j=1:imgSize1[3]
      imgshow1[i,j,:] = img1[:,i,j]
      imgshow2[i,j,:] = img2[:,i,j]
    end
  end

  PyPlot.subplot(211)
  PyPlot.imshow(imgshow1)
  PyPlot.subplot(212)
  PyPlot.imshow(imgshow2)
  gcf()

end

#= Problem 1
Load and Display =#

function problem1()
  img1 = loadimage()
  savefile(img1)
  img2 = loadfile()
  img2 = mirrorhorizontal(img2)
  showimages(img1, img2)
end

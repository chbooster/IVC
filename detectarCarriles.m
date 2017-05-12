function [ ] = detectarCarriles( videoIn )

msg = ['Leyendo fichero ',videoIn,' ...'];
disp(msg);

videoread = VideoReader(videoIn);
vidfinal = VideoWriter('videoProcesado.avi');
open(vidfinal);
%video = read(videoread);

numFrames = ceil(videoread.FrameRate*videoread.Duration);
time = cputime;

for frame = 1:videoread.NumberOfFrames
  currentFrame = read(videoread, frame);
  
  
  %Comienza la logica
  
 % currentFrame(:,:,2) = im2bw(currentFrame(:,:,2), graythresh(currentFrame(:,:,2)));

  filterFrame = currentFrame(:,:,1); %canal R solo
  filterFrame = medfilt2(filterFrame, [3 3]);
  filterFrame = im2bw(filterFrame, 0.999);
  
 % filterFrame = edge(filterFrame, 'sobel');

  %SE = strel('square', 5);
  %filterFrame = imopen(filterFrame, SE);
  cc = bwconncomp(filterFrame);
  L = labelmatrix(cc);
  s = regionprops(L, 'All');
  %descriptores:
  area = [s.Area];
  perimetro = [s.Perimeter];
  extent = [s.Extent];
  circularidad = (4 * pi*area) ./ (perimetro.*perimetro);
  excentricidad = [s.Eccentricity];
   id2 = find(excentricidad > 0.9 & circularidad < 0.2 & perimetro > 200);
   
  bw2 = ismember(L, id2(1));
  %imshow(bw2);
  cc = bwconncomp(bw2);
  L = labelmatrix(cc);
  s = regionprops(L, 'Area', 'Perimeter');

  cantidad = size([s],2);

  
  
 
  %imshow(bw2,'InitialMagnification', 60);
  
  rgbImage = cat(3, uint8(bw2*255), uint8(bw2*255), uint8(bw2*255));
  %Termina la logica
  
  writeVideo(vidfinal, rgbImage);
  clc;
  msg = ['Procesando el frame ',num2str(frame),' de ',num2str(videoread.NumberOfFrames),' (',num2str(ceil(frame/videoread.NumberOfFrames*100)),'%)'];
  msg2 = ['Figuras segmentadas: ',num2str(cantidad)];
  disp(msg);
  disp(msg2);
end

endTime = cputime-time;
msg = ['Tiempo de procesamiento: ',num2str(endTime),' segundos.'];
disp(msg);


end


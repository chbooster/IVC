function [ ] = detectarCarriles( videoIn )

msg = ['Leyendo fichero ',videoIn,' ...'];
disp(msg);

videoread = VideoReader(videoIn);             %apertura de ficheros in/out
vidfinal = VideoWriter('videoProcesado.avi');
open(vidfinal);
time = cputime; %para tomar métrica del tiempo de proceso

for frame = 1:videoread.NumberOfFrames
  currentFrame = read(videoread, frame);      %lectura de frame
 
  %Comienza la lógica
  
  filterFrame = currentFrame(:,:,1);          %canal R solo (el que mejor información de la linea tiene)
  filterFrame = medfilt2(filterFrame, [3 3]); %filtrado inicial
  filterFrame = im2bw(filterFrame, 0.999);    %binarizado
  
  %SE = strel('square', 5);                   %Op Morfologicas
  %filterFrame = imopen(filterFrame, SE);
  cc = bwconncomp(filterFrame);               %Comienza segmentación
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

  cc = bwconncomp(bw2);
  L = labelmatrix(cc);
  s = regionprops(L, 'Area', 'Perimeter');
  cantidad = size([s],2);
  
  %Termina la logica
  

  %Para visualizar el procesador en tiempo real (mas lento) 
  %imshow(bw2,'InitialMagnification', 60);  
  
  %Recomponer frame en RGB en vez de Gray (Necesario para el video)
  rgbImage = cat(3, uint8(bw2*255), uint8(bw2*255), uint8(bw2*255));
  writeVideo(vidfinal, rgbImage); %Escritura del frame en el video
  
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


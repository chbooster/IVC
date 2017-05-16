function [ ] = detectarCarriles( videoIn )

msg = ['Leyendo fichero ',videoIn,' ...'];
disp(msg);

videoread = VideoReader(videoIn);             %apertura de ficheros in/out
%vidfinal = VideoWriter('videoProcesado.avi');
%open(vidfinal);
ficheroTiempo = fopen('tiempos.txt','w');
fprintf(ficheroTiempo,'%6s %12s\n','Frame','Tiempo');

time = cputime; %para tomar métrica del tiempo de proceso
timeFrame = cputime;%para calcular el tiempo por frame

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

  circularidad = (4 * pi*area) ./ (perimetro.*perimetro);
  excentricidad = [s.Eccentricity];
  id2 = find(excentricidad > 0.9 & circularidad < 0.2 & perimetro > 200);
   
  bw2 = ismember(L, id2(1));
 
  cc = bwconncomp(bw2);
  L = labelmatrix(cc);
  s = regionprops(L, 'Area', 'Perimeter');
  cantidad = size([s],2);
  %Termina la logica
  
  BW3 = bwmorph(bw2,'skel',Inf);

  C = corner(BW3, 'MinimumEigenvalue', 200, 'FilterCoefficients' , fspecial('gaussian',[5 1],1.5), 'QualityLevel', 0.25);

  %Para visualizar el procesador en tiempo real (mas lento) 
  imshow(BW3,'InitialMagnification', 60);  
  
  clc;
  msg = ['Procesando el frame ',num2str(frame),' de ',num2str(videoread.NumberOfFrames),' (',num2str(ceil(frame/videoread.NumberOfFrames*100)),'%)'];
  msg2 = ['Figuras segmentadas: ',num2str(cantidad)];
  disp(msg);
  disp(msg2);
  
  endTimeFrame = cputime - timeFrame;
  timeFrame = cputime;
  fprintf(ficheroTiempo,'%d %12.8f\n',frame, endTimeFrame);
  
end

endTime = cputime-time;
msg = ['Tiempo de procesamiento: ',num2str(endTime),' segundos.'];
disp(msg);

fprintf(ficheroTiempo,'El tiempo total de procesamiento es: %8.3f \n', endTime);

end


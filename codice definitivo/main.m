%% 0 Pulisco l'ambiente
close all;
clear all;
clc;
[File_Name, Path_Name] = uigetfile({'*.jpg'},'Select a image file');
File_Path = fullfile(Path_Name, File_Name);
%% 1. Trovo il disco ottico
%Inizializzo l'immagine
I_rgb = imread(File_Path);
%Estraggo il canale verde dell'immagine
I_g = I_rgb(:,:,2); %%canale verde
I_green = adapthisteq(I_g); %% canale verde equalizzato
%Effettuo il thresholding secondo le direttive dell'articolo per individuare
%il disco ottico
%Prima di tutto, trovo la maschera del disco ottico
mask1 = bwconvhull(I_green > 218); % maschera del disco ottico
%Uso la funzione regionprops per trovare le coordinate del centro
props = regionprops(mask1, I_green, 'WeightedCentroid');
%centro disco ottico (xCenter,yC% enter)
xCenter= props.WeightedCentroid(1);
yCenter= props.WeightedCentroid(2);
subplot(1,2,1),imshow(I_g),title('Canale Verde');
%verifico che il punto trovato coincida con il centro del disco ottico
xline(xCenter, 'LineWidth', 2,'Color', 'r')
yline(yCenter, 'LineWidth', 2,'Color', 'r')
subplot(1,2,2),imshow(mask1),title('Maschera del disco ottico');
axis("on",'image');
hold on;
xline(xCenter, 'LineWidth', 2,'Color', 'r')
yline(yCenter, 'LineWidth', 2,'Color', 'r')
%% 2. Trovo il raggio ed il centro della Roi
% Raggio della Roi a 3 volte il diametro del disco ottico
matrix = myfunction(mask1,xCenter,yCenter);
radius = matrix(1,1);
%imposto il raggio della ROI a 7 volte il raggio del disco ottico
distance = 6.6*radius;
% Centro della Roi
%ora bisogna trovare il punto medio tra il centro ed il bordo dell'immagine
%estraggo la maschera del fondo retinale
mask2 = bwconvhull(I_g > 30); %% maschera del fondo retinale nell'immagine
matrix2 = myfunction(mask2, xCenter, yCenter); %funzione che calcola la distanza di un punto da tutti i punti del contorno
%estraggo tutti i punti di contorno della maschera che corrispondono al contorno dell'immagine del fondo retinale
%Trovo le coordinate del punto del bordo più lontano dal disco ottico
xEdge = matrix2(1,2);
yEdge = matrix2(1,3);
%trovo il punto medio su cui verrà centrata la ROI
xPtMedio = (xEdge + xCenter)/2;
yPtMedio = (yEdge + yCenter)/2;
subplot(1,3,1),imshow(I_g),title('Canale Verde della immagine');
roi = drawcircle("Center", [xPtMedio,yPtMedio], 'radius',distance,'StripeColor','red');
mask3 = createMask(roi); %% maschera della ROI
maskedImage1 = extractRoi(mask3,I_g);
subplot(1,3,2),imshow(maskedImage1),title('Region of Interest (ROI)');
%ROI canale rosso
maskedImage1_r = extractRoi(mask3,I_rgb(:,:,1));
%ROI canale blu
maskedImage1_b = extractRoi(mask3,I_rgb(:,:,3));
%ricombino i canali
maskedImage_rgb = cat(3, maskedImage1_r, maskedImage1, maskedImage1_b);
subplot(1,3,3),imshow(maskedImage_rgb),title('ROI RGB');
%% 3. filtro l'immagine secondo le direttive dell'articolo:
close all;
I_filteredA = medfilt2(I_g,[5 5]);
I_filteredB = medfilt2(I_g,[30 30]);
%risultato con immagine originale
%%I_diff = I_g - I_filteredB;
%Sottraggo le due immagini filtrate invece che l'immagine originale
%per rimuovere il rumore  e far emergere solamente i drusen
I_diff = I_filteredA - I_filteredB;
%equalizzo l'immagine mediante un filtro adattivo
I_eq = adapthisteq(I_diff);
I_eq_masked = extractRoi(mask3,I_eq);
I_diff_masked = extractRoi(mask3,I_diff);
%subplot(2,2,1),imshow(extractRoi(mask3,I_filteredA)),title('Filtro mediano 5x5');
%subplot(2,2,2),imshow(extractRoi(mask3,I_filteredB)),title('Filtro mediano 30x30');
%subplot(2,2,3),imshow(extractRoi(mask3,I_diff)),title('Immagine sottrazione');
%% 4. Applichiamo renyis
I_ent = renyisEntropy(I_diff);
I_ent_masked = extractRoi(mask3,I_ent);
%subplot(1,2,1),imshow(maskedImage1), title('Canale verde immagine');
%subplot(1,2,2),imshow(I_ent_masked),title('Segmentazione con Renyi');
%% 5. Segmentazione con Region Growing 
mask4 = bwconvhull(I_green > 210);
props = regionprops(mask4, I_g, 'WeightedCentroid');
xCenter2= props.WeightedCentroid(1);
yCenter2= props.WeightedCentroid(2);
matrix4 = myfunction(mask4,xCenter2,yCenter2);
xDisk= matrix4(1,2);
yDisk= matrix4(1,3);
%area vessel
S1 = double(I_diff(xDisk,yDisk));
D1 = double(max(max(I_diff_masked)) - min(min(I_diff_masked)));
T1 = 0.2*(D1/255);
I_diff_db = im2double(I_diff);
%segmento i vessel dell'immagine mediante la tecnica di region growing
g = regiongrow(I_diff_db, S1/255, T1);
S2 = double(I_eq(round(xCenter2),round(yCenter2)));
D2 = double(max(max(I_eq_masked)) - min(min(I_eq_masked)));
T2 = 0.2*(D2/255);
I_eq_db = im2double(I_eq);
%segmento il disco ottico dell'immagine mediante la tecnica di region growing
g2 = regiongrow(I_eq_db, S2/255, T2);
subplot(1,2,1),imshow(extractRoi(mask3,g)),title('g')
subplot(1,2,2),imshow(extractRoi(mask3,g2)),title('g2')
%% 4.1 eliminazione con double
%I_ent_db = im2double(I_ent);
%I_res = I_ent_db - g - g2;
%I_res_masked = extractRoi(mask3,I_res);
%subplot(1,3,1),imshow(I_ent_masked), title('ROI immagine estratta con Renyi');
%subplot(1,3,2),imshow(I_res_masked),title('ROI immagine risultante');
%subplot(1,3,3),imshow(maskedImage1),title(' ROI Canale verde');
%% 4.1 eliminazione con binary
I_res2 = I_ent - im2bw(g) - im2bw(g2);
I_res2_masked = extractRoi(mask3,I_res2);
%subplot(1,3,1),imshow(I_ent_masked), title('ROI immagine estratta con Renyi');
%subplot(1,3,2),imshow(I_res2_masked),title('ROI immagine risultante');
%subplot(1,3,3),imshow(maskedImage1),title(' ROI Canale verde');
%% Visualizzazione risultati completi
subplot(1,3,1),imshow(I_g),title('Canale verde immagine');
subplot(1,3,3),imshow(I_res2_masked),title('ROI post processing');
subplot(1,3,2),imshow(maskedImage1),title('ROI canale verde');
%% Confronto Renys con global thresolding
%I_ots = otsuthresh(I_diff);% -g -g2;
%I_GT = gThresh(I_diff);% -g -g2;
%subplot(1,4,1),imshow(I_ent_masked),title('ROI Renyi');
%subplot(1,4,2),imshow(extractRoi(mask3,I_GT)),title('ROI Global thresholding');
%subplot(1,4,3),imshow(extractRoi(mask3,I_ots)), title('ROI Otsu');
%subplot(1,4,4),imshow(maskedImage1), title('ROI canale verde');
%%subplot(1,3,3),imshow(maskedImage1), title('ROI canale verde');
%%% Confronto Renys con otsu
%subplot(1,3,1),imshow(I_ent_masked),title('Renyi');



#********************************** Cartographie sur R *******************************

#####################################################
# Projet : Analyse COVID-19 au S�n�gal: partie 1    #
# Auteur : Ousmane Sy Bodian,                       #
# Profil : Ing�nieur statisticien, Data scientist   # 
# Date d�but : 04/09/2020                           #
#####################################################


#----------------------- Librairies requises dans ce projet ----------------------

# Chargement des packages pour les donn�es g�om�triques

#*** Pour installer les packages
install.packages("tidyverse", dependencies = TRUE)
install.packages("sf", dependencies = TRUE)
#..................................................

# Vous faites la m�me chose pour le reste des packages 


#***--- Chargement des librairies 
library(tidyverse) # tidyverse data visualization package
library(sf)        # Permet de lire les donn�es g�om�triques
library(raster)    # Le fichier 'shapefile'
# Les packages de visualisation
library(tmap)      # for static and interactive maps
library(viridis)   # palette de couleur gradient
library(leaflet)   # for interactive maps
library(mapview)   # for interactive maps
# library(ggplot2) # tidyverse data visualization package
library(shiny)     # for web applications




#---------------------- Importation de la base de donn�es -----------------------


# La base de donn�es est mis � jours tous les jours
# Celle que nous affichons ici a �t� t�l�charger le 30-08-2020


# Jeux de donn�es 'regions_cas18-08-2020' : 
# Nbre de cas confirm�s du covid selon la r�gion
region <- read.csv("regions_cas_30-08-2020.csv", header = T, sep = ",") 

# Structure des variables
str(region)


#----------------------- Reconstitution de la base de donn�es --------------------


# Renommer le nom des r�gions en format 'nom de famille'
# C�d la premi�re lettre en Majuscule et le reste en minuscule
names(region) <- str_to_title(names(region))   

# Consultons la structure des variables
str(region)



#*** Renommer les noms de r�gion avec un accent
names(region)[7] <- "K�dougou"
names(region)[11] <- "Saint-Louis"
names(region)[12] <- "S�dhiou"
names(region)[14] <- "Thi�s"

# Consultons la structure des variables
str(region)




# Objectif dans cette partie est de faire comprendre � R 
# que la variable 'Date' est de type 'date' et non une variable 
# cat�gorielle comme le fait croire R

# Pour y rem�dier on utilise la fonction de parsing 'as.POSIXct()'
# qui permet de convertir cette variable en classe 'date'



#*** Conversion en type date 'POSIXct()'
region <- region %>%
  mutate(Date = as.POSIXct(Date)) %>%
  arrange(Date)

# V�rification de la structure de date
str(region) 




#*** Extraction du nbre cummul� de cas confirm�s

# le Nre cumul�s de cas 'confirm�s' du covid
confirmes <- region[region$Date == max(region$Date),][-1]

# Convertissons ce vecteur en valeur enti�res
confirmes2 <- as.integer(confirmes)

# Regroupons le vecteur 'Regions' et ' confirmes' dans une seule base en colonnes
covid19_region <- data.frame(Regions = as.character(names(confirmes)), confirmes = confirmes2)




#--------------------------- Importation du 'fichier shapefile -----------------------

# Un fichier 'shapefile' est le fichier qui contient les formes 
# g�om�trique de la carte. 
# Entre autres, c'est le fichier qui contient les positions
# g�ographiques cad les latitudes et les longitudes


# Shapefiles du S�n�gal avec les 14 r�gions administratives
# site : http://www.diva-gis.org/gdata

senegal <- st_read("SEN_adm1.shp", layer = "SEN_adm1", stringsAsFactors = F)


#--------------------------- Reconstitution du 'fichier shapefile' ----------------------

# Dans le fichier shapefiles, nous avons besoin que deux variables
# le nom des r�gions et les donn�es g�ographiques

# On cr�e une nouvelle variable
# qui va contenir le nom des r�gions
senegal$ID <- senegal$NAME_1

# Restreindre le jeux de donn�es 'senegal' � deux variables
# les r�gions et les donn�es g�om�triques
senegal <- senegal[c(11, 10)]


#********** Fusion entre les donn�es G�ographiques 'senegal' 
# et le jeux de donn�es 'covid19_region'
MapDataCovid <- inner_join(senegal, covid19_region, by = c("ID" = "Regions")) 


# Attention!!! car les commandes qui g�n�rent la carte
# ne prennent que les objets 'sf'
# V�rifions la classe
class(MapDataCovid)



# A pr�sent tout est OK pour Visualiser les carte



#----------------------------------- Visualisation des Cartes --------------------------------


#------------------************* Les cartes � ronds proportionnels ************--------------

# Librairie
library(ggplot2)


#*****----------- Premi�re Catre avec 'ggplot' --------------


# Etape 1 : Premi�re carte basique
ggplot(MapDataCovid) +
  geom_sf(aes(fill = confirmes))











# Etape 2 : Ajout des cercles proportionels aux nbre de cas confirm�s
ggplot(MapDataCovid) +
  geom_sf(aes(fill = confirmes)) +
  stat_sf_coordinates(aes(size = confirmes, fill = confirmes), color = "red", 
                      shape = 20, alpha = 0.6)

# size : taille proportionnelle aux nbre de cas confirm�s
# fill : repmlissage de la couleur des r�gions en fonction du nbre de cas confirm�s
# shape : la forme , 20 = cercle  et 22 = carr�
# alpha : la transparence des cercles rouges (saturation)









# Etape 3 : Modification � l'�chelle gradient du repmlissage des couleurs :  
ggplot(MapDataCovid) +
  geom_sf(aes(fill = confirmes)) +
  stat_sf_coordinates(aes(size = confirmes, fill = confirmes), color = "red",
                      shape = 20, alpha = 0.6) +
  scale_fill_gradient2(name = "Nbre de cas confirm�s", low = "lightcyan",
                       mid = "slategray1", high = "darkred")

# couleur claire quand le nbre de cas confirm�s est faible ;
# couleur rouge sombre quand le nbre de cas confirm�s est �lev�








# Etape 4 : Modification de la taille des cercles proportionnelles
ggplot(MapDataCovid) +
  geom_sf(aes(fill = confirmes)) +
  stat_sf_coordinates(aes(size = confirmes, fill = confirmes), color = "red",
                      shape = 20, alpha = 0.6) +
  scale_fill_gradient2(name = "Nbre de cas confirm�s", low = "lightcyan",
                       mid = "slategray1", high = "darkred") +
  scale_size_area(name = "confirm�s", max_size = 25)






# Etape 5 : Ajout de titre + changement de theme
ggplot(MapDataCovid) +
  geom_sf(aes(fill = confirmes)) +
  stat_sf_coordinates(aes(size = confirmes, fill = confirmes), color = "red",
                      shape = 20, alpha = 0.6) +
  scale_fill_gradient2(name = "Nbre de cas confirm�s", low = "lightcyan",
                       mid = "slategray1", high = "darkred") +
  scale_size_area(name = "confirm�s", max_size = 25) +
  ggtitle("Nombre de cas Confirm�s au S�n�gal\n jusqu'� ce jour 30 Ao�t 2020") +
  theme_minimal() # theme du fond





# Etape 6 : Ajout de l'�tiquette des diff�rentes r�gions administratives
ggplot(MapDataCovid) +
  geom_sf(aes(fill = confirmes)) +
  stat_sf_coordinates(aes(size = confirmes, fill = confirmes), color = "red",
                      shape = 20, alpha = 0.6) +
  scale_fill_gradient2(name = "confirm�s", low = "lightcyan",
                       mid = "slategray1", high = "darkred") +
  scale_size_area(name = "confirm�s", max_size = 25) +
  ggtitle("Nombre de cas Confirm�s au S�n�gal\n jusqu'� ce jour 30 Ao�t 2020") +
  theme_minimal() +
  geom_sf_text(aes(label = ID), vjust = -0.5, check_overlap = T,
               fontface = "italic", colour = "black")





# Etape 7 :

#------- Ajoutons le Nbre de cas confirm�s au nom des r�gions
# R�gion + Nbre de cas

MapDataCovid <- MapDataCovid %>%
  mutate(char1 = as.character(ID),
         char2=  as.character(confirmes), 
         ID2 = paste(char1, char2, sep = "\n"))

# Affichage
ggplot(MapDataCovid) +
  geom_sf(aes(fill = confirmes)) +
  stat_sf_coordinates(aes(size = confirmes, fill = confirmes), color = "red",
                      shape = 20, alpha = 0.6) +
  scale_fill_gradient2(name = "confirm�s", low = "lightcyan",
                       mid = "slategray1", high = "darkred") +
  scale_size_area(name = "confirm�s", max_size = 25) +
  ggtitle("Nombre de cas Confirm�s au S�n�gal\n jusqu'� ce jour 18 Ao�t 2020") +
  theme_minimal() +
  geom_sf_text(aes(label = ID2), vjust = -0.5, check_overlap = T,
               fontface = "italic", colour = "black")









# Etape 8 : Elimination des axes et de leurs �tiquettes
ggplot(MapDataCovid) +
  geom_sf(aes(fill = confirmes)) +
  stat_sf_coordinates(aes(size = confirmes, fill = confirmes), color = "red",
                      shape = 20, alpha = 0.6) +
  scale_fill_gradient2(name = "confirm�s", low = "lightcyan",
                       mid = "slategray1", high = "darkred") +
  scale_size_area(name = "confirm�s", max_size = 25) +
  ggtitle("Nombre de cas Confirm�s au S�n�gal\n jusqu'� ce jour 30 Ao�t 2020") +
  theme_minimal() +
  geom_sf_text(aes(label = ID2), vjust = -0.5, check_overlap = T,
               fontface = "italic", colour = "black") +
  theme(axis.title.x = element_blank(), # Supprimer l'�tiquette de l'axe des X
        axis.title.y = element_blank(), # Supprimer l'�tiquette de l'axe des Y
        axis.text = element_blank(),    # Supprimer les axes des X et Y
        legend.position = "bottom")     # Position de la l�gende en bas










#*****-------------------------- Deuxi�me Catre (Interactive) avec 'tm_shape()' --------------------------------

# Avec la librairie tmap
library(tmap) # for static and interactive maps

#*******------- Carte Interractive 



# Etape 1 : Importation de la carte du S�n�gal
tm_shape(MapDataCovid) + 
  tm_polygons()






# Etape 2 : Remplissage des r�gions selon le nbr de cas confirm�s
tm_shape(MapDataCovid) + 
  tm_polygons("confirmes")
# Rendre interractive la Carte
tmap_mode("view")
tmap_last()







# Etape 3 : Ajout de param�tres (arguments)
tm_shape(MapDataCovid) + 
  tm_polygons("confirmes", id = "ID2",
              title="Nombre de cas Confirm�s") 

# title : Titre









# Etape 4 : Modification de l'echelle de remplissage des couleurs

# Notre propre �chelle
breaks = c(0, 0.5, 1, 2, 4, 5, 10, 20, 80, 90) * 100
# Carte
tm_shape(MapDataCovid) + 
  tm_polygons("confirmes", id = "ID2",
              title="Nombre de cas Confirm�s", 
              breaks = breaks)

# breaks : permet de changer l'echelle de remplissage des couleurs












# Etape 5 : Ajout de l'�tiquette des noms de r�gions
tm_shape(MapDataCovid) + 
  tm_polygons("confirmes", id = "ID2",
              title="Nombre de cas Confirm�s", 
              breaks = breaks) +
  tm_text("ID2", scale = 1.3, shadow = T)  # ajout des noms de r�gion

# scale : taille de la police de carat�res












# Etape 6 : Ajout de cercles � rond proportionnel aux nbr de cas confirm�s
tm_shape(MapDataCovid) + 
  tm_polygons("confirmes", id = "ID2",
              title="Nombre de cas Confirm�s", 
              breaks = breaks) +
  tm_text("ID2", scale = 1.3, shadow = T) +
  tm_bubbles(size = "confirmes", col = "red", alpha = .5, scale = 5, shape = 20)

# size : taille suivant le nbr de cas confirm�s
# alpha : la transparence ou saturation
# shape = 20 : pour la forme ciculaire



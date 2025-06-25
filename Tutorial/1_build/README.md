En este primer apartado construiremos un nanoporo en una membrana con forma hexagonal y un bloque a partir de la estructura de una molécula de Si3N4.

- Primero, replicamos esta molécula para crear la membrana con el script replicateCrystal.tlc

- Segundo, imponemos los límites de esta membrana en forma hexagonal con el script cutHexagon.tlc (obtenemos archivos del tipo .bound y tmp.pdb, que es la temperatura)

- Tercero, realizamos el poro en la membrana con el script drillPore.tlc

- Cuarto, creamos el archivo .psf de la estructura con el script siliconNitridePSF.tlc (se crea archivo surf)

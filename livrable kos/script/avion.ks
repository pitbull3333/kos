// ---------- début du script décolage ----------
clearscreen.
set hauteur_vesseau to ALT:RADAR - 1.57.
BRAKES off.
LIGHTS on.
SHIP:PARTSTAGGED("mg")[0]:ACTIVATE().
SHIP:PARTSTAGGED("md")[0]:ACTIVATE().
set ship:control:mainthrottle to 1.
// calcul de l'anticipation
set conteur_temps to -1.
set anticipation to 0.
global function fonction_anticipation {
	if (conteur_temps = 0) {
		set delta_cap_positif_init to delta_cap_positif.
	}
	if (conteur_temps = 2) {
		set delta_cap_positif_actuel to delta_cap_positif.
		set anticipation to delta_cap_positif_actuel - delta_cap_positif_init.
		set conteur_temps to -1.
	}
	set conteur_temps to conteur_temps + 1.
}
// fin du calcul de l'anticipation
// garde l'avion au centre de la piste quand il décole
UNTIL GROUNDSPEED > 80 {
	set SHIP:CONTROL:PITCH to 1.// aide à stabilisé les aile de l'avion
	// calcul du cap
	set cap to vectorangle(ship:NORTH:forevector, ship:facing:forevector).
	set cap_delta to vectorangle(ship:NORTH:forevector, ship:facing:starvector).
	if (cap_delta < 90) {
		set cap to 360 - cap.
	}
	// fin du calcul du cap
	// calcul du cap_voulu
	if (SHIP:GEOPOSITION:LAT > -0.04860) {// a gauche du centre de la piste
		set ecart to SHIP:GEOPOSITION:LAT + 0.04860.
		set ecart to ecart * 100.
		if (ecart > 20) {
			set ecart to 20.
		}
		set cap_voulu to 90 + ecart.
	}
	if (SHIP:GEOPOSITION:LAT < -0.04860) {// a droite du centre de la piste
		set ecart to (SHIP:GEOPOSITION:LAT + 0.04860) * (-1).
		set ecart to ecart * 100.
		if (ecart > 20) {
			set ecart to 20.
		}
		set cap_voulu to 90 - ecart.
	}
	// fin du calcul du cap_voulu
	// calcul de l'ecart avec le cap_voulu
	set delta_cap to cap_voulu - cap.
	set delta_cap_positif to cap_voulu - cap.
	if(delta_cap_positif < 0){
		set delta_cap_positif to delta_cap_positif * (-1).
	}
	// fin de calcul de l'ecart avec le cap_voulu
	fonction_anticipation().
	set numerateur to 1.
	set denominateur to GROUNDSPEED.
	set ajout_roue to numerateur / denominateur.
	if(delta_cap < 0.05 AND delta_cap > -0.05){
		SET SHIP:CONTROL:WHEELSTEER to 0.
	}else{
		if(delta_cap > 0){
			if(anticipation > 0){
				SET SHIP:CONTROL:WHEELSTEER to SHIP:CONTROL:WHEELSTEER - ajout_roue.
			}else{
				SET SHIP:CONTROL:WHEELSTEER to 0.
			}
		}else{
			if(anticipation > 0){
				SET SHIP:CONTROL:WHEELSTEER to SHIP:CONTROL:WHEELSTEER + ajout_roue.
			}else{
				SET SHIP:CONTROL:WHEELSTEER to 0.
			}
		}
	}
	// fin de l'action sur la roue pour que l'avion reviaine dans l'axe de la piste.
}
set SHIP:CONTROL:PITCH to 0.
SET SHIP:CONTROL:WHEELSTEER to 0.
// fin de garde l'avion au centre de la piste quand il décole
UNTIL hauteur_vesseau > 5 {
	lock steering to heading(90,35,0).
	set hauteur_vesseau to ALT:RADAR - 1.57.
}
GEAR off.
LIGHTS off.
UNTIL SHIP:ALTITUDE > 17000 {
	lock steering to heading(90,20,0).
}
SHIP:PARTSTAGGED("mg")[0]:TOGGLEMODE().
SHIP:PARTSTAGGED("md")[0]:TOGGLEMODE().
UNTIL SHIP:APOAPSIS >= 100000 {// 200000 pour une orbite de 200000 km
	if (SHIP:ALTITUDE < 70000) {
		lock steering to heading(90,20,0).
	} ELSE if sasmode <> "prograde" {
		set ship:control:mainthrottle to 0.
		sas on.
		WAIT 1.
		print "prograde".
		set sasmode to "prograde".
		WAIT 3.
		set ship:control:mainthrottle to 1.
	}
	WAIT 1.//attantion temp de anvent coupure des moteur quand ont attin l'AP
}
set ship:control:mainthrottle to 0.
sas on.
WAIT 1.
set sasmode to "prograde".
WAIT 5.
set warp to 3.
WAIT UNTIL ETA:APOAPSIS <= 19.
set warp to 0.
set max_acc to ship:maxthrust / ship:mass.// attantion il faut que les réacteur soit activé
set temp_combustion to (2255 - ship:velocity:orbit:mag) / max_acc.// 2095 pour une orbite de 200000 km
//print "accélération : " + max_acc.
//print "vitesse orbitale prise en conte : " + ship:velocity:orbit:mag.
//print "temp de combustion : " + temp_combustion.
WAIT UNTIL ETA:APOAPSIS <= temp_combustion / 2.
//print "vitesse orbitale à la combustion : " + ship:velocity:orbit:mag.
set ship:control:mainthrottle to 1.
WAIT UNTIL ship:velocity:orbit:mag >= 2255.// 2095 pour une orbite de 200000 km
set ship:control:mainthrottle to 0.
sas off.
//SET SHIP:CONTROL:NEUTRALIZE to TRUE.// vous rend les commendes
// ---------- fin du script décolage ----------
// ---------- début du script atterrissage ----------
print "Vous pouvez accélérer le temps mais pas plus de 4.".
//clearscreen.
// gestion de la vitesse
set conteur_temps to -1.
set anticipation to 0.
global function fonction_vitesse {
	if (SHIP:ALTITUDE > 350) {
		if (conteur_temps = 0) {
			set gaze to ship:control:mainthrottle.
			set vo_ini to SHIP:AIRSPEED.
		}
		if (conteur_temps = 50) {
			set vo to SHIP:AIRSPEED.
			set delta_v to vo - vo_ini.
			if (SHIP:AIRSPEED < 110){
				if (delta_v < 0){
					set ship:control:mainthrottle to gaze + 0.025.
				} ELSE if SHIP:AIRSPEED < 100 {
					set ship:control:mainthrottle to gaze + 0.025.
				}
			}
			if (SHIP:AIRSPEED > 120){
				if (delta_v > 0){
					set ship:control:mainthrottle to gaze - 0.05.
				} ELSE if SHIP:AIRSPEED > 130 {
					set ship:control:mainthrottle to gaze - 0.05.
				}
			}
			set conteur_temps to -1.
		}
		set conteur_temps to conteur_temps + 1.
	}else{
		set ship:control:mainthrottle to 0.
		GEAR on.
		LIGHTS on.
	}
}
// fin de la gestion de la vitesse
// gestion de l'inclinaison des ailes
set conteur_temps_ailes to -1.
global function fonction_inclinaison_aile {
	PARAMETER inclinaison_aile_voulu.
	if (conteur_temps_ailes = 0) {
		set inclinaison_aile_init to 90 - vectorangle(up:forevector, ship:facing:starvector).
		set pourcentage_aileron to SHIP:CONTROL:ROLL.
	}
	if (conteur_temps_ailes = 5) {
		set inclinaison_aile_actuel to 90 - vectorangle(up:forevector, ship:facing:starvector).
		//print "inclinaison ailes : " + inclinaison_aile_actuel.
		//print "inclinaison ailes voulu : " + inclinaison_aile_voulu.
		set delta_inclinaison_aile to inclinaison_aile_actuel - inclinaison_aile_init.
		set delta_ajout_inclinaison_aile_positif to inclinaison_aile_actuel - inclinaison_aile_voulu.
		if (delta_ajout_inclinaison_aile_positif < 0) {
			set delta_ajout_inclinaison_aile_positif to delta_ajout_inclinaison_aile_positif * (-1).
		}
		//print "delta ajout inclinaison_aile positif : " + delta_ajout_inclinaison_aile_positif.
		set numerateur to delta_ajout_inclinaison_aile_positif / 400.
		set denominateur to SHIP:AIRSPEED / 4.
		set ajout_pourcentage_aileron to numerateur / denominateur.
		if (inclinaison_aile_actuel > inclinaison_aile_voulu -1){
			if (delta_inclinaison_aile > 0){
				set SHIP:CONTROL:ROLL to pourcentage_aileron + ajout_pourcentage_aileron.
			} ELSE if inclinaison_aile_actuel < inclinaison_aile_voulu -2 {
				set SHIP:CONTROL:ROLL to pourcentage_aileron + ajout_pourcentage_aileron.
			}
		}
		if (inclinaison_aile_actuel < inclinaison_aile_voulu + 1){
			if (delta_inclinaison_aile < 0){
				set SHIP:CONTROL:ROLL to pourcentage_aileron - ajout_pourcentage_aileron.
			} ELSE if inclinaison_aile_actuel > inclinaison_aile_voulu + 2 {
				set SHIP:CONTROL:ROLL to pourcentage_aileron - ajout_pourcentage_aileron.
			}
		}
		set conteur_temps_ailes to -1.
	}
	set conteur_temps_ailes to conteur_temps_ailes + 1.
}
// fin de la gestion de l'inclinaison des ailes
// gestion de l'altitude
set conteur_temps_tangage to -1.
set tangage_voulu to 3.
global function fonction_hauteur {
	PARAMETER cap_voulu_bis.
	if(SHIP:GROUNDSPEED > 90){
		// gestion de l'approche
		set hauteur_vesseau to SHIP:ALTITUDE - 70.
		set al to (SHIP:GEOPOSITION:LNG * - 1) -74.78.// réglage de la position de la ligne de déssente
		set al to 70 + (al * 1300).// réglage de la pente de la ligne de déssente
		if (SHIP:ALTITUDE < 150) {
			set al to 150.
		}
		set altitude_min to al - 15.
		set altitude_max to al + 15.
		set ecart_hauteur to hauteur_vesseau - al.
		set ecart_hauteur to (hauteur_vesseau - al) * (-1).
		if (ecart_hauteur < 0) {
			set tangage to ecart_hauteur / 50.
			if (tangage > -6) {
				set tangage to -6.
			}
		}
		if (ecart_hauteur > 0) {
			set tangage to ecart_hauteur / 25.
			if (tangage < 15) {
				set tangage to 15.
			}
		}
		if (tangage > 40) {
			set tangage to 40.
		}
		if (tangage < -10) {
			set tangage to -10.
		}
		if (hauteur_vesseau <= altitude_max AND hauteur_vesseau >= altitude_min) {
			if (tangage > -3) {
				set tangage to -3.
			}
		}
		lock steering to heading(cap_voulu_bis,tangage).
		//set delta_al_voulu to hauteur_vesseau - al.// uniqument pour l'affichage
		//print "delta altitude voulu : " + delta_al_voulu.
		//print "tangage : " + tangage.
		//print "PITCH : " + SHIP:CONTROL:PITCH.
	}else{
		// gestion de l'arrondi
		lock steering to heading(cap_voulu_bis,0).
		set tangage to 90 - vectorangle(up:forevector, ship:facing:forevector).
		set vs_ini to SHIP:VERTICALSPEED.
		if (conteur_temps_tangage = 0) {
			set tangage_initiale to 90 - vectorangle(up:forevector, ship:facing:forevector).
		}
		if (conteur_temps_tangage = 25) {
			set vs_voulu to -3.
			set pourcentage_tangage to SHIP:CONTROL:PITCH.
			set vs to SHIP:VERTICALSPEED.
			set vs_max to vs_voulu - 2.
			set vs_min to vs_voulu + 2.
			set vs_marge_max to vs_max - 2.
			set vs_marge_min to vs_min + 2.
			set acceleration to vs - vs_ini.
			set delta_tangage to tangage - tangage_initiale.
			set delta_ajout_tangage to tangage_initiale - tangage_voulu.
			set delta_ajout_pourcentage_tangage to 10 - vs.
			if (delta_ajout_tangage < 0) {
				set delta_ajout_tangage to delta_ajout_tangage * (-1).
			}
			if (delta_ajout_pourcentage_tangage < 0) {
				set delta_ajout_pourcentage_tangage to delta_ajout_pourcentage_tangage * (-1).
			}
			set ajout_pourcentage_pronfondeur to delta_ajout_tangage / 10.
			set ajout_pourcentage_tangage to delta_ajout_pourcentage_tangage / 100.
			set ajout_pourcentage_tangage_bis to delta_ajout_pourcentage_tangage / 200.
			if (SHIP:ALTITUDE < 80) {
				// on fait en sorte d'avoir un tangage positif
				//print "tangage cas 2 : " + tangage.
				if (tangage > tangage_voulu -1) {
					if (delta_tangage > 0){
						set SHIP:CONTROL:PITCH to pourcentage_tangage - ajout_pourcentage_pronfondeur.
					} ELSE if tangage < tangage_voulu -2 {
						set SHIP:CONTROL:PITCH to pourcentage_tangage - ajout_pourcentage_pronfondeur.
					}
				}
				if (tangage < tangage_voulu + 1) {
					if (delta_tangage < 0){
						set SHIP:CONTROL:PITCH to pourcentage_tangage + ajout_pourcentage_pronfondeur.
					} ELSE if tangage > tangage_voulu + 2 {
						set SHIP:CONTROL:PITCH to pourcentage_tangage + ajout_pourcentage_pronfondeur.
					}
				}
				if(tangage > 5){
					//print "ok".
					set SHIP:CONTROL:PITCH to 0.
				}
			}else{
				// on gere la vitesse verticale
				//print "tangage cas 1 : " + tangage.
				if (SHIP:VERTICALSPEED > vs_min){
					if (acceleration > 0){
						set SHIP:CONTROL:PITCH to pourcentage_tangage - ajout_pourcentage_tangage_bis.
					} ELSE if SHIP:VERTICALSPEED > vs_marge_min {
						set SHIP:CONTROL:PITCH to pourcentage_tangage - ajout_pourcentage_tangage_bis.
					}
				}
				if (SHIP:VERTICALSPEED < vs_max) {
					if (acceleration < 0){
						set SHIP:CONTROL:PITCH to pourcentage_tangage + ajout_pourcentage_tangage.
					} ELSE if SHIP:VERTICALSPEED < vs_marge_max {
						set SHIP:CONTROL:PITCH to pourcentage_tangage + ajout_pourcentage_tangage.
					}
				}
				if (SHIP:CONTROL:PITCH > 0.5) {
					set SHIP:CONTROL:PITCH to 0.5.
				}
				if (SHIP:CONTROL:PITCH < -0.2) {
					set SHIP:CONTROL:PITCH to -0.2.
				}
				if (VERTICALSPEED > vs_marge_min AND SHIP:CONTROL:PITCH > 0) {
					set SHIP:CONTROL:PITCH to 0.
				}
				if (VERTICALSPEED < vs_marge_max AND SHIP:CONTROL:PITCH < 0.3) {
					set SHIP:CONTROL:PITCH to 0.3.
				}
				//print "VS : " + SHIP:VERTICALSPEED + " PITCH : " + SHIP:CONTROL:PITCH.
			}
			if (SHIP:ALTITUDE < 75) {
				//print "tangage : " + tangage + " GROUNDSPEED : " + SHIP:GROUNDSPEED.
			}
			set conteur_temps_tangage to -1.
		}
		set conteur_temps_tangage to conteur_temps_tangage + 1.
	}
}
// fin de la gestion de l'altitude
// gestion de la descente
set warp to 3.
WAIT UNTIL SHIP:GEOPOSITION:LNG < -50.
WAIT UNTIL SHIP:GEOPOSITION:LNG > -114.5.// ce raproche de 0 en ce raprochan de de la piste.
clearscreen.
set warp to 0.
sas off.
set cap to vectorangle(ship:NORTH:forevector, ship:facing:forevector).
set cap_delta to vectorangle(ship:NORTH:forevector, ship:facing:starvector).
if (cap_delta < 90) {
	set cap to 360 - cap.
}
set roullie to 90 - vectorangle(up:forevector, ship:facing:starvector).
set tangage to 90 - vectorangle(up:forevector, ship:facing:forevector).
UNTIL cap < 271 AND cap > 269 AND roullie < 1 AND roullie > -1 AND tangage < 1 AND tangage > -1 {
	lock steering to heading(270,0,0).
	set cap to vectorangle(ship:NORTH:forevector, ship:facing:forevector).
	set cap_delta to vectorangle(ship:NORTH:forevector, ship:facing:starvector).
	if (cap_delta < 90) {
		set cap to 360 - cap.
	}
	set roullie to 90 - vectorangle(up:forevector, ship:facing:starvector).
	set tangage to 90 - vectorangle(up:forevector, ship:facing:forevector).
}
set ship:control:mainthrottle to 1.
UNTIL ship:velocity:orbit:mag < 1500 {
	lock steering to heading(270,0,0).
}
set ship:control:mainthrottle to 0.
UNTIL cap < 91 AND cap > 89 AND roullie < 1 AND roullie > -1 AND tangage < 1 AND tangage > -1 {
	lock steering to heading(90,0,0).
	set cap to vectorangle(ship:NORTH:forevector, ship:facing:forevector).
	set cap_delta to vectorangle(ship:NORTH:forevector, ship:facing:starvector).
	if (cap_delta < 90) {
		set cap to 360 - cap.
	}
	set roullie to 90 - vectorangle(up:forevector, ship:facing:starvector).
	set tangage to 90 - vectorangle(up:forevector, ship:facing:forevector).
}
set warp to 3.
UNTIL SHIP:ALTITUDE < 69500 {
	lock steering to heading(90,0,0).
}
set warp to 3.
UNTIL SHIP:ALTITUDE < 17000 {
	lock steering to heading(90,0,0).
}
SHIP:PARTSTAGGED("mg")[0]:TOGGLEMODE().
SHIP:PARTSTAGGED("md")[0]:TOGGLEMODE().
UNTIL SHIP:ALTITUDE < 12000 {
	lock steering to heading(90,0,0).
}
set warp to 0.
UNTIL SHIP:ALTITUDE < 10070 {
	lock steering to heading(90,-10,0).
}
UNTIL SHIP:AIRSPEED < 800 {
	lock steering to heading(90,5,0).
}
// fin de la gestion de la descente
UNTIL SHIP:ALTITUDE < 72 {
	// calcul du cap_voulu
	if (SHIP:GEOPOSITION:LAT > -0.04860) {// a gauche du centre de la piste
		set ecart to SHIP:GEOPOSITION:LAT + 0.04860.
		set ecart to ecart * 100.
		if (ecart > 20) {
			set ecart to 20.
		}
		set cap_voulu to 90 + ecart.
	}
	if (SHIP:GEOPOSITION:LAT < -0.04860) {// a droite du centre de la piste
		set ecart to (SHIP:GEOPOSITION:LAT + 0.04860) * (-1).
		set ecart to ecart * 100.
		if (ecart > 20) {
			set ecart to 20.
		}
		set cap_voulu to 90 - ecart.
	}
	// fin du calcul du cap_voulu
	// calcul de l'ecart avec le cap_voulu
	set cap_prograde to vectorangle(ship:NORTH:forevector, ship:PROGRADE:forevector).//n'est valable que dans ce cas ou on est dans une zone du globe.
	set delta_cap_prograde to cap_voulu - cap_prograde.
	// fin de calcul de l'ecart avec le cap_voulu
	// mais l'avion dans l'axe de la piste tout en gerent la hauteur et la vitesse
	set geoposition_lat_positif to SHIP:GEOPOSITION:LAT.
	if(SHIP:GEOPOSITION:LAT < 0){
		set geoposition_lat_positif to SHIP:GEOPOSITION:LAT * (-1).
	}
	set ecart_piste_lat_positif to 0.04860 - geoposition_lat_positif.
	if(ecart_piste_lat_positif < 0){
		set ecart_piste_lat_positif to ecart_piste_lat_positif * (-1).
	}
	set degre_inclinaison_aile to 5 + (ecart_piste_lat_positif * 300).
	if(degre_inclinaison_aile > 20){
		set degre_inclinaison_aile to 20.
	}
	fonction_vitesse().
	fonction_hauteur(cap_voulu).
	//print "cap voulu : " + cap_voulu.
	//print "cap prograde : " + cap_prograde.
	if(SHIP:GEOPOSITION:LNG < -74.72839){
		if(delta_cap_prograde < 0.05 AND delta_cap_prograde > -0.05){
			//print "OK".
			fonction_inclinaison_aile(0).
		}else{
			//print "PAS OK".
			if(delta_cap_prograde > 0){
				fonction_inclinaison_aile(-degre_inclinaison_aile).// on ce dirige par la droite
			}else{
				fonction_inclinaison_aile(degre_inclinaison_aile).// on ce dirige par la gauche
			}
		}
		//clearscreen.
	}else{
		fonction_inclinaison_aile(0).
	}
}
WAIT 2.
BRAKES on.
UNTIL SHIP:GROUNDSPEED < 2 {
	lock steering to heading(90,0,0).
}
LADDERS on.
LIGHTS off.
SET SHIP:CONTROL:NEUTRALIZE to TRUE.// vous rend les commendes
//-74.69982 band blanche (zone de toucher)
//-74.72481 position inissiale de l'avion sur la piste.
//-74.72839 debut de piste
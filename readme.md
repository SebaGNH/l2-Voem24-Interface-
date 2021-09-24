#00  Interface limpia

#01  Agregado mensaje ConstructoMental en verde abajo a la derecha
    MenuWnd.uc
        Cambio mensaje en línea "44"
        cambio colores a verde líneas "40,41,42"


#02
    OptionWnd.uc
        Cambio msje google en línea "1623"


#03 Cambio tamaño buff de 32 a 18
    FlexOptionWnd.uc
"321"   	if (temp == 18)
"556"  		s_handle.SetIconSize(18);
"557" 		SetINIInt("Buff Control", "Size", 18, "PatchSettings");
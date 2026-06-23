void kernel_main(void) {
    // Puntero a la memoria de video VGA texto
    char *video_memory = (char *)0xB8000;
    
    // Mensaje temporal de marcador de posición
    const char *message = "Ingenieria en Sistemas la mejor carrera de la UIDE.";
    
    // 1. Limpiar la pantalla de residuos del arranque (80 columnas x 25 filas)
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video_memory[i] = ' ';
        video_memory[i+1] = 0x07; // Atributo estándar: Texto gris, fondo negro
    }

    // 2. Imprimir el mensaje personalizado en la primera línea
    int i = 0;
    int offset = 0;
    while (message[i] != '\0') {
        video_memory[offset] = message[i];     // Carácter ASCII
        video_memory[offset+1] = 0x0F;         // Atributo: Texto blanco brillante, fondo negro
        i++;
        offset += 2;                           // Cada carácter en pantalla usa 2 bytes
    }
}
global main
extern printf, gets, sscanf

section     .data
    msgElegirOpcion     db  "Ingrese 'c' si quiere codificar, ingrese 'd' si quiere decodificar: ",0
    msgOpcionInvalido   db  "El caracter ingresado, no es valido, intente otra vez.   ",0
    mensajeTexto        db  "Ingrese el texto: ",0
    mensajeNumero       db  "Ingrese el numero con el cual codificara su mensaje. (se aceptan entre 0 y 9): ",0
    msgNumInvalido      db  "El numero no es valido, intente otra vez.   ",0
    msgImpNum		    db  "El valor elegido es %i !",10,0
    msgTerminado        db  "El texto cambiado es: ",0
	numFormat		    db	"%li",0	

section     .bss
    mensaje_cifrado     resb 100
    valor_numero        resb 10
    caracter_elegido    resb 10
    numero              resq 1
    inputValido         resb 1  ; Es un booleanos para saber si es o no valido un resultado. Puede ser S o N
    

section     .text
main:
    ; Muestra el mensaje para codificar o decodificar el texto ingresado
    mov     rcx, msgElegirOpcion
    sub     rsp,32
    call    printf
    add     rsp,32
    
    ; Lee la cadena ingresada
    mov     rcx, caracter_elegido
    sub     rsp,32
    call    gets
    add     rsp,32
    
    ; me fijo si el caracter elegido es valido
    sub     rsp,32
    call    validarCodificacion
    add     rsp,32

    ; Si la validacion fue exitosa salta a "IngreseTexto" sino muesta error y regresa a main
    cmp     byte[inputValido],"S"
    je      IngreseTexto

    ; En caso de que sea invalido... 
    mov     rcx, msgOpcionInvalido
    sub     rsp, 32
    call    printf
    add     rsp, 32    
    jmp     main

IngreseTexto:
    ; Muestra el mensaje de solicitud para la cadena
    mov     rcx,mensajeTexto
    sub     rsp,32
    call    printf
    add     rsp,32
    
    ; Lee la cadena ingresada
    mov     rcx, mensaje_cifrado
    sub     rsp,32
    call    gets
    add     rsp,32


ingresoNumero:
    ; Muestra el mensaje de solicitud para el número
    mov     rcx,mensajeNumero
    sub     rsp,32
    call    printf
    add     rsp,32
    
    ; Lee el número ingresado
    mov     rcx, valor_numero
    sub     rsp,32
    call    gets
    add     rsp,32
    
    ; verfica que el numero ingresado este correcto
    sub     rsp,32
    call    validarNumero
    add     rsp,32

ret

finString:
    ; Ud ingreso <numero>
	mov	  rcx,msgImpNum
	mov	  rdx,[numero]
	sub   rsp,32
    call  printf
    add   rsp,32

    ; Muestra por pantalla el mensaje ya cifrado
    mov   rcx, msgTerminado
    sub   rsp,32
    call  printf
    add   rsp,32

    mov   rcx, mensaje_cifrado
    sub   rsp,32
    call  printf
    add   rsp,32
    
ret

;------------------------------------------------------------------------------------------

continuar:
;   Comparo el caracter para ver si es fin del texto, y cambio el caracter por el caracter cifrado
    mov    rsi,0
compCaracter:
    ; Si es el fin del texto, termina el programa
    cmp    byte[mensaje_cifrado+rsi],0
    je     finString
    
    ; Si es un espacio sigue al siguiete caracter
    cmp    byte[mensaje_cifrado+rsi]," "
    je     sgteCarac

    ; Sumo el valor ingresado al caracter
    cmp    byte[caracter_elegido],"c"
    je     sumarCaracter
    
    ; Resto el valor ingresado al caracter
    cmp    byte[caracter_elegido],"d"
    je     restarCaracter


sumarCaracter:
   mov     ah,0

sumCarac:
   mov     al, [numero]
   cmp	   al, ah
   jg	   continuarSuma
   jmp     sgteCarac

continuarSuma:
   
   ; Comparo si el caracter es una "z"
    cmp    byte[mensaje_cifrado+rsi],"z"
    je     cambiarCaracterMinuscula

   ; Comparo si el caracter es una "Z"
    cmp    byte[mensaje_cifrado+rsi],"Z"
    je     cambiarCaracterMayuscula

    inc    byte[mensaje_cifrado+rsi]
    inc    ah
    jmp    sumCarac 

;Cambia el caracter para volver a empezar por la a
cambiarCaracterMinuscula:
    mov    byte[mensaje_cifrado+rsi],"a"
    dec    byte[mensaje_cifrado+rsi]
    jmp    sumCarac

;Cambia el caracter para volver a empezar por la A
cambiarCaracterMayuscula:
    mov    byte[mensaje_cifrado+rsi],"A"
    dec    byte[mensaje_cifrado+rsi]
    jmp    sumCarac


restarCaracter:
   mov     ah,0
resCarac:
   mov     al, [numero]
   cmp	   al, ah
   jg	   continuarResta
   jmp     sgteCarac

continuarResta:
   ; Comparo si el caracter es una "a"
    cmp    byte[mensaje_cifrado+rsi],"a"
    je     cambiarCaracterMinusculaResta

   ; Comparo si el caracter es una "A"
    cmp    byte[mensaje_cifrado+rsi],"A"
    je     cambiarCaracterMayusculaResta

    dec    byte[mensaje_cifrado+rsi]
    inc    ah
    jmp    resCarac 

;Cambia el caracter para volver a empezar por la z
cambiarCaracterMinusculaResta:
    mov   byte[mensaje_cifrado+rsi],"z"
    inc   byte[mensaje_cifrado+rsi]
    jmp   resCarac

;Cambia el caracter para volver a empezar por la Z
cambiarCaracterMayusculaResta:
    mov   byte[mensaje_cifrado+rsi],"Z"
    inc   byte[mensaje_cifrado+rsi]
    jmp   resCarac


sgteCarac:    
    inc   rsi
    jmp   compCaracter
 
;valida si el usuario ingresa bien el caracter para Codificar o Decodificar
validarCodificacion:
    mov   byte[inputValido],"N"

    cmp   byte[caracter_elegido],"c"
    je    valido
    cmp   byte[caracter_elegido],"d"
    je    valido

    ret

valido:
    mov   byte[inputValido],"S"
    ret

validarNumero:   
    ; Convierto el valor_numero a un entero
    mov	  rcx,valor_numero   
	mov	  rdx,numFormat	   
	mov	  r8,numero		   
	sub   rsp,32
    call  sscanf
    add   rsp,32

    ; Comparo que el numero no este fuera de rango, y que no sea distinto de un numero
    cmp	  rax,1		
    jl	  numeroInvalido
   
    cmp	  word[numero],0  
	jl	  numeroInvalido
	
    cmp	  word[numero],9
	jg	  numeroInvalido

    jmp   continuar

numeroInvalido:
    ; En caso de que sea invalido... 
    mov   rcx, msgNumInvalido
    sub   rsp, 32
    call  printf
    add   rsp, 32    
    jmp   ingresoNumero

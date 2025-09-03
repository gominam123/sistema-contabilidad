<?php
session_start();

// Configuración de la base de datos
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'sistema_contabilidad');

// Establecer la cabecera para la respuesta JSON
header('Content-Type: application/json');

// Función para enviar una respuesta JSON y terminar el script
function json_response($success, $message) {
    echo json_encode(['success' => $success, 'message' => $message]);
    exit();
}

// Establecer conexión con la base de datos
try {
    $conn = new PDO("mysql:host=".DB_HOST.";dbname=".DB_NAME, DB_USER, DB_PASS);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    json_response(false, 'Error de conexión: ' . $e->getMessage());
}

// Procesar el formulario solo si el método es POST
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    json_response(false, 'Método no permitido.');
}

$usuario = trim($_POST["txtusuario"] ?? '');
$contrasena = trim($_POST["txtcontrasena"] ?? '');

// Validar que los campos no estén vacíos
if (empty($usuario) || empty($contrasena)) {
    json_response(false, 'Por favor, complete todos los campos.');
}

// Consulta preparada para evitar inyección SQL
try {
    $stmt = $conn->prepare("SELECT id, usuario, contrasena, nombre_completo FROM usuarios WHERE usuario = :usuario");
    $stmt->bindParam(':usuario', $usuario, PDO::PARAM_STR);
    $stmt->execute();
    
    if ($stmt->rowCount() == 1) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // *** EL PUNTO CLAVE ESTÁ AQUÍ ***
        // password_verify() compara la contraseña del formulario ($contrasena)
        // con el HASH guardado en la base de datos ($user['contrasena']).
        // Si tu contraseña en la base de datos no es un hash, esto SIEMPRE fallará.
        if (password_verify($contrasena, $user['contrasena'])) {
            // La contraseña es correcta, iniciamos la sesión
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['username'] = $user['usuario'];
            $_SESSION['nombre_completo'] = $user['nombre_completo'];
            
            json_response(true, 'Inicio de sesión exitoso');
        } else {
            // La contraseña no coincide
            json_response(false, 'Usuario o contraseña incorrectos.');
        }
    } else {
        // El usuario no existe
        json_response(false, 'Usuario o contraseña incorrectos.');
    }
} catch(PDOException $e) {
    json_response(false, 'Error en la consulta: ' . $e->getMessage());
}

?>

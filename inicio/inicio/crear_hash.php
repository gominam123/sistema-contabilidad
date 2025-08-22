<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Generador de Hash de Contraseña</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-900 text-white min-h-screen flex items-center justify-center font-sans">

    <div class="container mx-auto p-8 bg-gray-800 rounded-lg shadow-lg max-w-lg">
        <h1 class="text-3xl font-bold text-center text-cyan-400 mb-4">Generador de Hash para Contraseñas</h1>
        <p class="text-center text-gray-400 mb-6">Usa esta herramienta para cifrar tu contraseña. Luego, copia el resultado y pégalo en la columna 'contrasena' de tu tabla 'usuarios' en la base de datos.</p>

        <form method="post" class="space-y-4">
            <div>
                <label for="password" class="block text-lg font-medium text-gray-300">Contraseña a Cifrar:</label>
                <input type="text" name="password" id="password" required
                       class="mt-1 block w-full bg-gray-700 border border-gray-600 rounded-md shadow-sm py-2 px-3 text-white focus:outline-none focus:ring-cyan-500 focus:border-cyan-500">
            </div>
            <div>
                <button type="submit"
                        class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-cyan-600 hover:bg-cyan-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500">
                    Generar Hash
                </button>
            </div>
        </form>

        <?php
        // Procesar el formulario si se ha enviado una contraseña
        if (isset($_POST['password']) && !empty($_POST['password'])) {
            $password = $_POST['password'];

            // Generar el hash de la contraseña. PASSWORD_BCRYPT es el algoritmo recomendado.
            $hash = password_hash($password, PASSWORD_BCRYPT);

            // Mostrar el resultado
            echo '<div class="mt-8 p-4 bg-gray-900 rounded-lg">';
            echo '<h2 class="text-xl font-semibold text-green-400">¡Hash Generado!</h2>';
            echo '<p class="text-gray-400 mt-2">Copia este texto completo:</p>';
            echo '<textarea readonly class="w-full h-24 mt-2 p-2 bg-gray-700 text-green-300 rounded-md font-mono break-all" onclick="this.select();">' . htmlspecialchars($hash) . '</textarea>';
            echo '</div>';
        }
        ?>
    </div>

</body>
</html>

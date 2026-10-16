// Middleware penanganan error global
const errorHandler = (err, req, res, next) => {
  // Log error untuk keperluan debugging (development)
  console.error('Error:', err.message);
  console.error('Stack:', err.stack);

  // Kirim respons error tanpa mengekspos stack trace
  return res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan pada server.',
  });
};

module.exports = errorHandler;

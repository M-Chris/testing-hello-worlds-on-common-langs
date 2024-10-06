use actix_web::{web, App, HttpServer, Responder};
use std::env;

async fn hello() -> impl Responder {
    web::Json(serde_json::json!({"message": "Hello World"}))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Get the number of CPUs available
    let num_workers = env::var("WORKERS").unwrap_or_else(|_| "16".to_string());
    let num_workers: usize = num_workers.parse().unwrap_or(16); // Default to 16 workers

    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(hello))
    })
    .workers(num_workers) // Set number of workers (threads)
    .bind("0.0.0.0:8000")?
    .run()
    .await
}
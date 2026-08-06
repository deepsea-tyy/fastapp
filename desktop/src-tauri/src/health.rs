use std::net::TcpStream;
use std::time::Duration;

use serde::Serialize;

#[derive(Debug, Clone, Serialize)]
pub struct ServiceHealth {
    pub hyperf: bool,
    pub scheduler: bool,
}

pub fn tcp_open(host: &str, port: u16) -> bool {
    TcpStream::connect_timeout(
        &format!("{host}:{port}").parse().unwrap(),
        Duration::from_millis(800),
    )
    .is_ok()
}

pub fn check() -> ServiceHealth {
    ServiceHealth {
        hyperf: tcp_open("127.0.0.1", 9501),
        scheduler: tcp_open("127.0.0.1", 8312),
    }
}

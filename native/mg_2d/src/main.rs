extern crate redis;
use redis::Commands;
use std::env;
use std::process;

fn main() {
    let exit_code = run();

    std::process::exit(exit_code);
}

fn run() -> i32 {
    let args: Vec<_> = env::args().collect();

    if args.len() > 1 {
        tick(&args[1]);
        0
    } else {
        1
    }
}

fn tick(channel_name: &str) -> redis::RedisResult<isize> {
    let client = try!(redis::Client::open("redis://127.0.0.1/"));
    let mut pubsub = try!(client.get_pubsub());

    println!("{}", channel_name);
    try!(pubsub.subscribe(channel_name));
    loop {
        let msg = try!(pubsub.get_message());
        let payload : String = try!(msg.get_payload());

        println!("{}", payload);
    }
}

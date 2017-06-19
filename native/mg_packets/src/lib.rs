#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;
extern crate regex;
use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};
use rustler::types::list::NifListIterator;
use regex::Regex;

rustler_export_nifs! {
    "Elixir.Moongate.NativeModules.Packets",
    [("decode", 1, decode),
    ("encode", 6, encode)],
    Some(on_load)
}

mod atoms {
    rustler_atoms! {
        atom ok;
    }
}

fn decode<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let packet: &str = try!(args[0].decode());
    let designator: String = parse_designator(packet);
    let zm: String = decode_field(&designator, r"\(([^\)]+)\)");
    let rm: String = decode_field(&designator, r"\{([^\)]+)\}");
    let cm: String = decode_field(&designator, r"<([^\)]+)>");
    let hm: String = decode_field(&designator, r"\[([^\)]+)\]");
    let bm: String = decode_field(&packet, r"::(.*)");
    let result = vec![zm, rm, cm, hm, bm];

    Ok((atoms::ok(), result.encode(env)).encode(env))
}

fn parse_designator(packet: &str) -> String {
    if packet.contains("::") {
        split_field(packet, r"::(.*)")
    } else {
        format!("{}", packet)
    }
}

fn decode_field(packet: &str, regexp_string: &str) -> String {
    let regexp = Regex::new(regexp_string).unwrap();

    match regexp.captures(packet) {
        None => format!("{}", ""),
        _ => {
            let caps = regexp.captures(packet).unwrap();
            format!("{}", caps.get(1).map_or("", |m| m.as_str()))
        },
    }
}

fn split_field(packet: &str, regexp_string: &str) -> String {
    let regexp = Regex::new(regexp_string).unwrap();
    let result: Vec<&str> = regexp.split(packet).collect();
    format!("{}", result[0])
}

fn encode<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let b: String = encode_body(try!(args[0].decode()));
    let h: String = encode_chunk(try!(args[1].decode()), "[", "]");
    let r: String = encode_chunk(try!(args[2].decode()), "{", "}");
    let t: String = encode_chunk(try!(args[3].decode()), "<", ">");
    let z: String = encode_zone(try!(args[4].decode()), try!(args[5].decode()));
    let result: String = format!("#{}{}{}{}{}", z, r, t, h, b);

    Ok((atoms::ok(), result).encode(env))
}

fn encode_body(body: &str) -> String {
    match body {
        "" => format!("{}", ""),
        _ => format!("::{}", body),
    }
}

fn encode_zone(zone: &str, zone_id: &str) -> String {
    match (zone, zone_id) {
         ("", "") => format!("{}", ""),
         ("", zone) => format!("({})", zone),
         _ => format!("({}:{})", zone, zone_id),
    }
}

fn encode_chunk(body: &str, startToken: &str, endToken: &str) -> String {
    match body {
        "" => format!("{}", ""),
        _ => format!("{}{}{}", startToken, body, endToken)
    }
}

fn on_load<'a>(env: NifEnv<'a>, _load_info: NifTerm<'a>) -> bool {
    true
}

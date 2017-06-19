#[macro_use] extern crate rustler;
#[macro_use] extern crate rustler_codegen;
#[macro_use] extern crate lazy_static;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};

mod atoms {
    rustler_atoms! {
        atom ok;
    }
}

rustler_export_nifs! {
    "Elixir.Moongate.NativeModules.Math",
    [("add", 2, add),
    ("subtract", 2, subtract),
    ("multiply", 2, multiply),
    ("divide", 2, divide)],
    Some(on_load)
}

fn add<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: f64 = try!(args[0].decode());
    let num2: f64 = try!(args[1].decode());

    Ok((atoms::ok(), num1 + num2).encode(env))
}

fn subtract<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: f64 = try!(args[0].decode());
    let num2: f64 = try!(args[1].decode());

    Ok((atoms::ok(), num1 - num2).encode(env))
}

fn multiply<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: f64 = try!(args[0].decode());
    let num2: f64 = try!(args[1].decode());

    Ok((atoms::ok(), num1 * num2).encode(env))
}

fn divide<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let num1: f64 = try!(args[0].decode());
    let num2: f64 = try!(args[1].decode());

    Ok((atoms::ok(), num1 / num2).encode(env))
}

fn on_load<'a>(env: NifEnv<'a>, _load_info: NifTerm<'a>) -> bool {
    true
}

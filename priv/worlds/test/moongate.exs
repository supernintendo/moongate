%{
  anonymous: false,
  sockets: [
    {:tcp, 7593},
    {:udp, 7594},
    {:ws, 7595},
    {:http, 7596, "http"}
  ]
}
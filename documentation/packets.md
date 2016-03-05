Packets
=======

 Moongate and its clients communicate over TCP, UDP or WebSockets using packets which conform to an opinionated format. This document serves as a specification for those packets.

Fundamentally, a Moongate packet should obey the following template:

<pre>
<a href="#packet">size</a><sup>1</sup>{<a href="#timestamp">timestamp</a><sup>2</sup>·<sup>3</sup><a href="#content">context</a><sup>4</sup>·action·arguments<sup>5</sup>}
</pre>

This structure provides a rough means to differentiate and contextualize individual packets from a stream of data.

<small>
<ol type="1">
<li>
`size` refers to the number of bytes of all non-delimiter characters within the curly braces.
</li>
<li>
Unix time. This is only sent by the Moongate server.
</li>
<li>
Interpunct (`·`) is the default <a href="#delimiters">delimiter</a>. It may be overridden by a world's `server.json`.
</li>
<li>
Multiple contexts may be delimited by periods.
</li>
<li>
Any delimiter-separated strings past this point are treated as separate arguments.
</li>
</ol>
</small>

## Context
Context has a different meaning depending on if the packet is sent from the server or a client.

Serverside, sending outgoing packets is done by way of a macro which references the registered name of the process delivering the packet. This name is used as the context of the outgoing packet.

For example, every stage sends a packet when a client arrives to it that might look something like this:

<pre>
46{1454897654592·<em>stage_login_screen</em>·transaction·join}
</pre>

For packets that are coming from the client, context refers to the pool within the current target stage that the message targets. For instance, a client moving the player character up might send the following packet:

<pre>
12{<em>Player</em>·walk·0·1}
</pre>

If more than one deed on a pool exports a function with the same name, the function is called on all deeds. You can choose to call it only on a specific deed using dot notation:

<pre>
12{Player.<em>Movement</em>·walk·0·1}
</pre>

Context may be omitted from client packets. In this case, the message is passed to the `takes` function on the current target stage. Thus, the following packet:

<pre>
17{message·hello·world}
</pre>

Would call the following on the current target stage:

<pre>
takes({<em>message</em>, <em>params</em>}, event)
</pre>

... with `message` being `"message"` and params being `["hello", "world"]` in this example.

## Delimiters
By default, any interpunct (`·`) is treated as a boundary between two values (also known as a delimiter). You may set a custom delimiter by assigning a string to the `delimiter` property of your world's `server.json`.

## Packet Size  
The number that begins each packet is the size of all non-delimiter characters within the first set of curly braces. For example, take the following packet:

<pre>
<em>21</em>{auth·login·test·moongate}
</pre>

The entire string is 31 bytes. If we only look at characters within the braces (`auth·login·test·moongate`), we're left with 27 bytes. Finally, if we exclude the delimiters (`·`, 2 bytes) we get a message of 21 bytes.

The Moongate server rejects packets with an incorrect packet size. This is to account for bad packets, perhaps as a result of Nagle's algorithm or UDP packet corruption.

## Timestamp
The Moongate server includes a Unix timestamp with every outgoing packet. It is the first part of the message, like so:

<pre>
41{<em>1454782557714</em>·stage_dungeon·transaction·join}
</pre>

The timestamp is needed for pool transforms since the client needs to consider latency when predicting the server side state of a changing value. As a result, it may be excluded from server packets where it is unneccessary in future versions.

Clients should not send timestamps to the Moongate server.
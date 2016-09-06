defmodule Moongate.OS.Sockets do
  @brace_op_close "}"
  @brace_op_open "{"
  @brace_domain_close ")"
  @brace_domain_open "("
  @brace_target_close ">"
  @brace_target_open "<"
  @digit_length 2
  @domains %{
    world: 0x00,
    stage: 0x01,
    pool: 0x02
  }
  @operations %{
    message: 0x00,
    add: 0x01,
    remove: 0x02,
    join: 0x03,
    leave: 0x04,
    set: 0x05,
    mutate: 0x06,
    request: 0x07,
    ping: 0x08,
    status: 0x09
  }
  @fence "|"
  @pad "~^~"

  def socket_message(origin, {op, domain, target, body}) when is_nil(target) do
    GenServer.cast(origin.events, {:write, socket_msg_tmpl(op, domain, body)})
  end
  def socket_message(origin, {op, domain, target, body}) do
    GenServer.cast(origin.events, {:write, socket_msg_tmpl(op, domain, target, body)})
  end

  def socket_msg_tmpl(op, domain, body) do
    "#{@fence}#{@pad}"
    <> "#{@brace_op_open}#{Hexate.encode(@operations[op], @digit_length)}#{@brace_op_close}"
    <> "#{@brace_domain_open}#{Hexate.encode(@domains[domain], @digit_length)}#{@brace_domain_close}"
    <> body
    <> "#{@pad}#{@fence}"
  end

  def socket_msg_tmpl(op, domain, target, body) do
    "#{@fence}#{@pad}"
    <> "#{@brace_op_open}#{Hexate.encode(@operations[op], @digit_length)}#{@brace_op_close}"
    <> "#{@brace_domain_open}#{Hexate.encode(@domains[domain], @digit_length)}#{@brace_domain_close}"
    <> "#{@brace_target_open}#{target}#{@brace_target_close}"
    <> body
    <> "#{@pad}#{@fence}"
  end
end

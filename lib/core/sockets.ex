defmodule Moongate.Core.Sockets do
  @brace_domain_open "("
  @brace_domain_close ")"

  @brace_target_open "<"
  @brace_target_close ">"

  @digit_length 2
  @operations Moongate.Packets.operations
  @prefix "#"

  def socket_message(origin, {op, domain, target, body}) when is_nil(target) do
    GenServer.cast(origin.events, {:write, socket_msg_tmpl(op, domain, body)})
  end
  def socket_message(origin, {op, domain, target, body}) do
    GenServer.cast(origin.events, {:write, socket_msg_tmpl(op, domain, target, body)})
  end

  def socket_operations, do: @operations

  def socket_msg_tmpl(op, domain, body) do
    "#{@prefix}"
    <> "#{@brace_domain_open}#{domain}:#{Hexate.encode(@operations[op], @digit_length)}#{@brace_domain_close}"
    <> "::#{body}"
  end

  def socket_msg_tmpl(op, domain, target, body) do
    "#{@prefix}"
    <> "#{@brace_domain_open}#{domain}:#{Hexate.encode(@operations[op], @digit_length)}#{@brace_domain_close}"
    <> "#{@brace_target_open}#{target}#{@brace_target_close}"
    <> "::#{body}"
  end
end

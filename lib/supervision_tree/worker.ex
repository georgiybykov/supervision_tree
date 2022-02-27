defmodule SupervisionTree.Worker do
  @moduledoc """
  This is a simple worker implementation with starting
  and terminating functionality to show how it works
  with different supervision strategies.

  It also includes the ability to join one custom
  process group in order to broadcast and receive
  messages from other processes.
  """

  use GenServer

  require Logger

  @spec start_link(any()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:label], opts)
  end

  @doc "Stops the worker"
  @spec stop(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: :ok
  def stop(worker), do: GenServer.stop(worker)

  @impl true
  @spec init(atom()) :: {:ok, atom()}
  def init(label) do
    # First we have to start the main scope for the process group.
    :pg.start_link()

    # Now we can create a custom scope.
    :pg.start_link(:feedback)

    # Exit signals arriving to a process are
    # converted to {'EXIT', From, Reason} messages,
    # which can be received as ordinary messages.
    Process.flag(:trap_exit, true)

    :pg.join(:feedback, self())

    log("#{label}: is starting")

    broadcast(label, :started)

    {:ok, label}
  end

  @impl true
  def handle_info({_event, _label}, state) do
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, label) do
    log("#{label}: is terminating")

    broadcast(label, :stopped)
  end

  @spec broadcast(atom(), atom()) :: :ok
  defp broadcast(label, event) do
    Enum.each(
      :pg.get_members(:feedback),
      fn pid -> Process.send(pid, {event, label}, [:nosuspend]) end
    )
  end

  @spec log(binary()) :: :ok | nil
  defp log(label) do
    if Mix.env() != :test, do: Logger.info(label)
  end
end

defmodule SupervisionTree.Application do
  @moduledoc """
  Supervision Tree - is an application includes supervisors and
  workers using different strategies for initialize and restart.
  """

  use Application

  alias SupervisionTree.Worker

  @typedoc "The list of Supervisor initialize strategies."
  @type strategy() :: :one_for_one | :one_for_all | :rest_for_one

  @typedoc "The list of Worker restart strategies."
  @type restart() :: :permanent | :temporary | :transient

  @typedoc "Describes the Worker module child spec."
  @type supervisor_child_spec() ::
          %{id: non_neg_integer(), restart: atom(), start: tuple()}

  @impl true
  @spec start(any(), any()) :: {:ok, pid()} | {:error, any()}
  def start(_type, _args) do
    children = [
      worker(:main_worker_with_permanent_restart),
      worker(:main_worker_with_transient_restart, :transient),
      supervisor(
        [
          worker(:first_worker),
          worker(:second_worker),
          worker(:third_worker)
        ],
        strategy: :one_for_one,
        name: :first_supervisor
      ),
      supervisor(
        [
          worker(:fourth_worker),
          worker(:fifth_worker),
          worker(:sixth_worker)
        ],
        strategy: :one_for_all,
        name: :second_supervisor
      ),
      supervisor(
        [
          worker(:seventh_worker),
          worker(:eighth_worker),
          worker(:ninth_worker),
          supervisor(
            [worker(:sub_worker)],
            strategy: :one_for_one,
            name: :sub_supervisor
          )
        ],
        strategy: :rest_for_one,
        name: :third_supervisor
      )
    ]

    # This is the main supervisor who runs and supervises all children identified above.
    opts = [strategy: :one_for_one, name: SupervisionTree.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec supervisor([supervisor_child_spec()], strategy: atom(), name: atom()) ::
          %{id: non_neg_integer(), start: tuple()}
  defp supervisor(children, [strategy: _, name: _] = options) do
    %{
      id: id(),
      start: {Supervisor, :start_link, [children, options]}
    }
  end

  @spec worker(atom(), restart()) :: supervisor_child_spec()
  defp worker(name, restart \\ :permanent) do
    Supervisor.child_spec(
      {Worker, [label: name, name: name]},
      id: id(),
      restart: restart
    )
  end

  # Child specs of the Supervisor require unique IDs.
  @spec id() :: non_neg_integer()
  defp id, do: :erlang.unique_integer([:positive])
end

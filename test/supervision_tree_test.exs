defmodule SupervisionTreeTest do
  use ExUnit.Case, async: true

  alias SupervisionTree.Worker

  setup do
    :pg.start_link()

    :pg.start_link(:feedback)

    # Join feedback group so we can listen for messages from worker processes
    :pg.join(:feedback, self())

    :ok
  end

  test "restart main worker" do
    Worker.stop(:main_worker_with_permanent_restart)

    assert_receive {:stopped, :main_worker_with_permanent_restart}
    assert_receive {:started, :main_worker_with_permanent_restart}

    refute_received {:stopped, _}
    refute_received {:started, _}
  end

  test "stop main worker with transient restart: the worker will not be restarted" do
    Worker.stop(:main_worker_with_transient_restart)

    assert_receive {:stopped, :main_worker_with_transient_restart}
    refute_receive {:started, :main_worker_with_transient_restart}

    refute_received {:stopped, _}
    refute_received {:started, _}
  end

  # If a child process terminates, only that process is restarted.
  test "one_for_one supervisor strategy: stopped worker will be the only one restarted" do
    Worker.stop(:first_worker)

    assert_receive {:stopped, :first_worker}
    assert_receive {:started, :first_worker}

    refute_received {:stopped, :second_worker}
    refute_received {:started, :second_worker}
    refute_received {:stopped, :third_worker}
    refute_received {:started, :third_worker}

    Worker.stop(:second_worker)

    refute_received {:stopped, :first_worker}
    refute_received {:started, :first_worker}

    assert_receive {:stopped, :second_worker}
    assert_receive {:started, :second_worker}

    refute_received {:stopped, :third_worker}
    refute_received {:started, :third_worker}

    Worker.stop(:third_worker)

    refute_receive {:stopped, :first_worker}
    refute_receive {:started, :first_worker}

    refute_received {:stopped, :second_worker}
    refute_received {:started, :second_worker}

    assert_receive {:stopped, :third_worker}
    assert_receive {:started, :third_worker}
  end

  # If a child process terminates, all other child processes are terminated
  # and then all child processes (including the terminated one) are restarted.
  test "one_for_all supervisor strategy: if you stop any worker, then all of them will be restarted" do
    Worker.stop(:fourth_worker)

    assert_receive {:stopped, :fourth_worker}
    assert_receive {:started, :fourth_worker}
    assert_receive {:stopped, :fifth_worker}
    assert_receive {:started, :fifth_worker}
    assert_receive {:stopped, :sixth_worker}
    assert_receive {:started, :sixth_worker}

    Worker.stop(:fifth_worker)

    assert_receive {:stopped, :fourth_worker}
    assert_receive {:started, :fourth_worker}
    assert_receive {:stopped, :fifth_worker}
    assert_receive {:started, :fifth_worker}
    assert_receive {:stopped, :sixth_worker}
    assert_receive {:started, :sixth_worker}

    Worker.stop(:sixth_worker)

    assert_receive {:stopped, :fourth_worker}
    assert_receive {:started, :fourth_worker}
    assert_receive {:stopped, :fifth_worker}
    assert_receive {:started, :fifth_worker}
    assert_receive {:stopped, :sixth_worker}
    assert_receive {:started, :sixth_worker}
  end

  # If a child process terminates, the terminated child process and the
  # rest of the children started after it, are terminated and restarted.
  test "rest_for_one supervisor strategy" do
    Worker.stop(:seventh_worker)

    assert_receive {:stopped, :seventh_worker}
    assert_receive {:started, :seventh_worker}
    assert_receive {:stopped, :eighth_worker}
    assert_receive {:started, :eighth_worker}
    assert_receive {:stopped, :ninth_worker}
    assert_receive {:started, :ninth_worker}
    assert_receive {:stopped, :sub_worker}
    assert_receive {:started, :sub_worker}

    Worker.stop(:eighth_worker)

    refute_received {:stopped, :seventh_worker}
    refute_received {:started, :seventh_worker}

    assert_receive {:stopped, :eighth_worker}
    assert_receive {:started, :eighth_worker}
    assert_receive {:stopped, :ninth_worker}
    assert_receive {:started, :ninth_worker}
    assert_receive {:stopped, :sub_worker}
    assert_receive {:started, :sub_worker}

    Worker.stop(:ninth_worker)

    refute_received {:stopped, :seventh_worker}
    refute_received {:started, :seventh_worker}
    refute_received {:stopped, :eighth_worker}
    refute_received {:started, :eighth_worker}

    assert_receive {:stopped, :ninth_worker}
    assert_receive {:started, :ninth_worker}
    assert_receive {:stopped, :sub_worker}
    assert_receive {:started, :sub_worker}
  end
end

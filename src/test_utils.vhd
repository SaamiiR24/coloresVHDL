library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package test_utils is

  type wait_active_edge is (WAIT_RISING_EDGE, WAIT_FALLING_EDGE);

  procedure generate_clock (
    signal clock : out std_logic;
    period       :     time;
    duty         :     real      := 0.5;
    start_at     :     std_logic := '0'
  );

  procedure wait_n_edges (
    signal clock : std_logic;
    num          : positive         := 1;
    wait_on      : WAIT_ACTIVE_EDGE := WAIT_RISING_EDGE
  );

  procedure generate_pulse (
    signal clock  :       std_logic;
    signal target : inout std_logic;
    length        :       positive  := 1;
    delay         :       positive  := 1;
    value         :       std_logic := '1'
  );

  procedure generate_pulse (
    signal clock  :       std_logic;
    signal target : inout std_logic_vector;
    length        :       positive := 1;
    delay         :       positive := 1;
    value         :       std_logic_vector
  );

  procedure generate_pulse (
    signal target : inout std_logic;
    length        :       time;
    delay         :       time      := 0 ns;
    value         :       std_logic := '1'
  );

  procedure generate_pulse (
    signal target : inout std_logic_vector;
    length        :       time;
    delay         :       time := 0 ns;
    value         :       std_logic_vector
  );

end package test_utils;

package body test_utils is

  procedure generate_clock (
    signal clock : out std_logic;
    period       :     time;
    duty         :     real      := 0.5;
    start_at     :     std_logic := '0'
  ) is

    variable t1, t2 : time;

  begin

    assert duty > 0.0 and duty < 1.0
      report "[FATAL]: DUTY must belong to (0.0, 1.0)"
      severity failure;

    if (start_at = '0') then
      t1 := (1.0 - duty) * period;
    else
      t1 := duty * period;
    end if;

    t2 := period - t1;

    loop

      clock <= start_at;
      wait for t1;
      clock <= not start_at;
      wait for t2;

    end loop;

  end procedure generate_clock;

  procedure wait_n_edges (
    signal clock : std_logic;
    num          : positive         := 1;
    wait_on      : WAIT_ACTIVE_EDGE := WAIT_RISING_EDGE
  ) is
  begin

    for i in 1 to num loop

      if (wait_on = WAIT_RISING_EDGE) then
        wait until clock = '1';
      else
        wait until clock = '0';
      end if;

    end loop;

    wait for 0 ns;

  end procedure wait_n_edges;

  procedure generate_pulse (
    signal clock  :       std_logic;
    signal target : inout std_logic;
    length        :       positive  := 1;
    delay         :       positive  := 1;
    value         :       std_logic := '1'
  ) is

    variable target_initial_value : std_logic;

  begin

    wait_n_edges(clock, delay);
    target_initial_value := target;
    target               <= value;
    wait_n_edges(clock, length);
    target               <= target_initial_value;
    wait for 0 ns;

  end procedure generate_pulse;

  procedure generate_pulse (
    signal clock  :       std_logic;
    signal target : inout std_logic_vector;
    length        :       positive := 1;
    delay         :       positive := 1;
    value         :       std_logic_vector
  ) is

    variable target_initial_value : std_logic_vector(target'range);

  begin

    assert value'length = target'length
      report "[FATAL]: VALUE and TARGET must have the same length."
      severity failure;

    wait_n_edges(clock, delay);
    target_initial_value := target;
    target               <= value;
    wait_n_edges(clock, length);
    target               <= target_initial_value;
    wait for 0 ns;

  end procedure generate_pulse;

  procedure generate_pulse (
    signal target : inout std_logic;
    length        :       time;
    delay         :       time      := 0 ns;
    value         :       std_logic := '1'
  ) is

    variable target_initial_value : std_logic;

  begin

    wait for delay;
    target_initial_value := target;
    target               <= value;
    wait for length;
    target               <= target_initial_value;
    wait for 0 ns;

  end procedure generate_pulse;

  procedure generate_pulse (
    signal target : inout std_logic_vector;
    length        :       time;
    delay         :       time := 0 ns;
    value         :       std_logic_vector
  ) is

    variable target_initial_value : std_logic_vector(target'range);

  begin

    assert value'length = target'length
      report "[FATAL]: VALUE and TARGET must have the same length."
      severity failure;

    wait for delay;
    target_initial_value := target;
    target               <= value;
    wait for length;
    target               <= target_initial_value;
    wait for 0 ns;

  end procedure generate_pulse;

end package body test_utils;

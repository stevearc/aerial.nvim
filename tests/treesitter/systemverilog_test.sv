interface rdy_vld_if
endinterface

module dut(dut_if dif);
  for (genvar i=0; i<4; i++)
    task my_task();
    endtask

  for (genvar i=0; i<4; i++) begin: g_named
    task my_task();
    endtask
  end
endmodule

class my_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_rx0#(my_transaction, my_scoreboard) item_collected_export_rx0;

  int q[2][2][$];

  function new(string name, uvm_component parent);
  endfunction

  function write_rx0(my_transaction pkt);
  endfunction

endclass

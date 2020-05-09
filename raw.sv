//if(drv_pkt.wr_trans_type == wr_trans::WR_WITH_WAIT) begin
      wait(apb_vif.pready === 1);
      apb_vif.pdata <= drv_pkt.pdata;
    end
    else begin
      if(apb_vif.pready === 1)begin
        apb_vif.pdata <= drv_pkt.pdata;
      end
      else begin
        apb_vif.pslverr <= 1;
      end 
    end


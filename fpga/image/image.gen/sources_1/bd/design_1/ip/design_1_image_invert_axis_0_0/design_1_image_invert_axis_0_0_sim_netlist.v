// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
// Date        : Sat Oct  3 13:02:42 2026
// Host        : MSI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/eziochen/Desktop/fpga_project/fpga/image/image.gen/sources_1/bd/design_1/ip/design_1_image_invert_axis_0_0/design_1_image_invert_axis_0_0_sim_netlist.v
// Design      : design_1_image_invert_axis_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_image_invert_axis_0_0,image_invert_axis,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "image_invert_axis,Vivado 2026.1" *) 
(* NotValidForBitStream *)
module design_1_image_invert_axis_0_0
   (aclk,
    aresetn,
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tlast,
    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tready,
    m_axis_tlast);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF m_axis:s_axis, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *) input s_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *) output s_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TLAST" *) input s_axis_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [31:0]m_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *) output m_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *) input m_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *) output m_axis_tlast;

  wire aclk;
  wire aresetn;
  wire [31:0]m_axis_tdata;
  wire m_axis_tlast;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [31:0]s_axis_tdata;
  wire s_axis_tlast;
  wire s_axis_tvalid;

  assign s_axis_tready = m_axis_tready;
  design_1_image_invert_axis_0_0_image_invert_axis inst
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tvalid(s_axis_tvalid));
endmodule

(* ORIG_REF_NAME = "image_invert_axis" *) 
module design_1_image_invert_axis_0_0_image_invert_axis
   (m_axis_tdata,
    m_axis_tlast,
    m_axis_tvalid,
    s_axis_tdata,
    aclk,
    s_axis_tlast,
    m_axis_tready,
    s_axis_tvalid,
    aresetn);
  output [31:0]m_axis_tdata;
  output m_axis_tlast;
  output m_axis_tvalid;
  input [31:0]s_axis_tdata;
  input aclk;
  input s_axis_tlast;
  input m_axis_tready;
  input s_axis_tvalid;
  input aresetn;

  wire aclk;
  wire aresetn;
  wire [31:0]m_axis_tdata;
  wire \m_axis_tdata[31]_i_2_n_0 ;
  wire m_axis_tlast;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire m_axis_tvalid_i_1_n_0;
  wire p_0_in;
  wire [31:0]p_2_in;
  wire [31:0]s_axis_tdata;
  wire s_axis_tlast;
  wire s_axis_tvalid;

  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[0]_i_1 
       (.I0(s_axis_tdata[0]),
        .O(p_2_in[0]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[10]_i_1 
       (.I0(s_axis_tdata[10]),
        .O(p_2_in[10]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[11]_i_1 
       (.I0(s_axis_tdata[11]),
        .O(p_2_in[11]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[12]_i_1 
       (.I0(s_axis_tdata[12]),
        .O(p_2_in[12]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[13]_i_1 
       (.I0(s_axis_tdata[13]),
        .O(p_2_in[13]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[14]_i_1 
       (.I0(s_axis_tdata[14]),
        .O(p_2_in[14]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[15]_i_1 
       (.I0(s_axis_tdata[15]),
        .O(p_2_in[15]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[16]_i_1 
       (.I0(s_axis_tdata[16]),
        .O(p_2_in[16]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[17]_i_1 
       (.I0(s_axis_tdata[17]),
        .O(p_2_in[17]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[18]_i_1 
       (.I0(s_axis_tdata[18]),
        .O(p_2_in[18]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[19]_i_1 
       (.I0(s_axis_tdata[19]),
        .O(p_2_in[19]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[1]_i_1 
       (.I0(s_axis_tdata[1]),
        .O(p_2_in[1]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[20]_i_1 
       (.I0(s_axis_tdata[20]),
        .O(p_2_in[20]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[21]_i_1 
       (.I0(s_axis_tdata[21]),
        .O(p_2_in[21]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[22]_i_1 
       (.I0(s_axis_tdata[22]),
        .O(p_2_in[22]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[23]_i_1 
       (.I0(s_axis_tdata[23]),
        .O(p_2_in[23]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[24]_i_1 
       (.I0(s_axis_tdata[24]),
        .O(p_2_in[24]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[25]_i_1 
       (.I0(s_axis_tdata[25]),
        .O(p_2_in[25]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[26]_i_1 
       (.I0(s_axis_tdata[26]),
        .O(p_2_in[26]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[27]_i_1 
       (.I0(s_axis_tdata[27]),
        .O(p_2_in[27]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[28]_i_1 
       (.I0(s_axis_tdata[28]),
        .O(p_2_in[28]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[29]_i_1 
       (.I0(s_axis_tdata[29]),
        .O(p_2_in[29]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[2]_i_1 
       (.I0(s_axis_tdata[2]),
        .O(p_2_in[2]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[30]_i_1 
       (.I0(s_axis_tdata[30]),
        .O(p_2_in[30]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[31]_i_1 
       (.I0(aresetn),
        .O(p_0_in));
  LUT2 #(
    .INIT(4'h8)) 
    \m_axis_tdata[31]_i_2 
       (.I0(s_axis_tvalid),
        .I1(m_axis_tready),
        .O(\m_axis_tdata[31]_i_2_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[31]_i_3 
       (.I0(s_axis_tdata[31]),
        .O(p_2_in[31]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[3]_i_1 
       (.I0(s_axis_tdata[3]),
        .O(p_2_in[3]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[4]_i_1 
       (.I0(s_axis_tdata[4]),
        .O(p_2_in[4]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[5]_i_1 
       (.I0(s_axis_tdata[5]),
        .O(p_2_in[5]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[6]_i_1 
       (.I0(s_axis_tdata[6]),
        .O(p_2_in[6]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[7]_i_1 
       (.I0(s_axis_tdata[7]),
        .O(p_2_in[7]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[8]_i_1 
       (.I0(s_axis_tdata[8]),
        .O(p_2_in[8]));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[9]_i_1 
       (.I0(s_axis_tdata[9]),
        .O(p_2_in[9]));
  FDRE \m_axis_tdata_reg[0] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[0]),
        .Q(m_axis_tdata[0]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[10] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[10]),
        .Q(m_axis_tdata[10]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[11] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[11]),
        .Q(m_axis_tdata[11]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[12] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[12]),
        .Q(m_axis_tdata[12]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[13] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[13]),
        .Q(m_axis_tdata[13]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[14] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[14]),
        .Q(m_axis_tdata[14]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[15] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[15]),
        .Q(m_axis_tdata[15]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[16] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[16]),
        .Q(m_axis_tdata[16]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[17] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[17]),
        .Q(m_axis_tdata[17]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[18] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[18]),
        .Q(m_axis_tdata[18]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[19] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[19]),
        .Q(m_axis_tdata[19]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[1] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[1]),
        .Q(m_axis_tdata[1]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[20] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[20]),
        .Q(m_axis_tdata[20]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[21] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[21]),
        .Q(m_axis_tdata[21]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[22] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[22]),
        .Q(m_axis_tdata[22]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[23] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[23]),
        .Q(m_axis_tdata[23]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[24] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[24]),
        .Q(m_axis_tdata[24]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[25] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[25]),
        .Q(m_axis_tdata[25]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[26] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[26]),
        .Q(m_axis_tdata[26]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[27] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[27]),
        .Q(m_axis_tdata[27]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[28] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[28]),
        .Q(m_axis_tdata[28]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[29] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[29]),
        .Q(m_axis_tdata[29]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[2] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[2]),
        .Q(m_axis_tdata[2]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[30] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[30]),
        .Q(m_axis_tdata[30]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[31] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[31]),
        .Q(m_axis_tdata[31]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[3] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[3]),
        .Q(m_axis_tdata[3]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[4] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[4]),
        .Q(m_axis_tdata[4]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[5] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[5]),
        .Q(m_axis_tdata[5]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[6] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[6]),
        .Q(m_axis_tdata[6]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[7] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[7]),
        .Q(m_axis_tdata[7]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[8] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[8]),
        .Q(m_axis_tdata[8]),
        .R(p_0_in));
  FDRE \m_axis_tdata_reg[9] 
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(p_2_in[9]),
        .Q(m_axis_tdata[9]),
        .R(p_0_in));
  FDRE m_axis_tlast_reg
       (.C(aclk),
        .CE(\m_axis_tdata[31]_i_2_n_0 ),
        .D(s_axis_tlast),
        .Q(m_axis_tlast),
        .R(p_0_in));
  LUT4 #(
    .INIT(16'hE200)) 
    m_axis_tvalid_i_1
       (.I0(m_axis_tvalid),
        .I1(m_axis_tready),
        .I2(s_axis_tvalid),
        .I3(aresetn),
        .O(m_axis_tvalid_i_1_n_0));
  FDRE m_axis_tvalid_reg
       (.C(aclk),
        .CE(1'b1),
        .D(m_axis_tvalid_i_1_n_0),
        .Q(m_axis_tvalid),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif

module vending_machine (
							i_clk,
							i_rst_n,
							i_money,
							i_money_valid,
							i_product_code,
							i_buy,
							i_product_ready,

							o_product_code,  
							o_product_valid,
							o_busy,
							o_change_denomination_code,
							o_change_valid,
							o_no_change
						);

		  
		  
localparam ESPRESSO  = 1, 
		   AMERICANO = 2,
		   LATTE	 = 3,
		   TEA		 = 4,
		   MILK		 = 5,
		   CHOCOLATE = 6,
		   NUTS	     = 7,
		   SNICKERS  = 8;		

		   
		   
parameter  	PRICE_PROD_ONE   = 320,
			PRICE_PROD_TWO   = 350,
			PRICE_PROD_THREE = 400,
			PRICE_PROD_FOUR  = 420,
			PRICE_PROD_FIVE  = 450,
			PRICE_PROD_SIX   = 300,
			PRICE_PROD_SEVEN = 900,
			PRICE_PROD_EIGHT = 800;

			
			
localparam	   DENOMINATION_CODE_500 = 1,  DENOMINATION_VALUE_500 = 50000,
			   DENOMINATION_CODE_200 = 2,  DENOMINATION_VALUE_200 = 20000,
			   DENOMINATION_CODE_100 = 3,  DENOMINATION_VALUE_100 = 10000,
			   DENOMINATION_CODE_50  = 4,  DENOMINATION_VALUE_50  = 5000,
			   DENOMINATION_CODE_20  = 5,  DENOMINATION_VALUE_20  = 2000,
			   DENOMINATION_CODE_10  = 6,  DENOMINATION_VALUE_10  = 1000,
			   DENOMINATION_CODE_5   = 7,  DENOMINATION_VALUE_5   = 500,
			   DENOMINATION_CODE_2   = 8,  DENOMINATION_VALUE_2   = 200,
			   DENOMINATION_CODE_1   = 9,  DENOMINATION_VALUE_1   = 100,
			   DENOMINATION_CODE0_50 = 10, DENOMINATION_VALUE_0_50 = 50, 
			   DENOMINATION_CODE0_25 = 11, DENOMINATION_VALUE_0_25 = 25,
			   DENOMINATION_CODE0_10 = 12, DENOMINATION_VALUE_0_10 = 10,
			   DENOMINATION_CODE0_05 = 13, DENOMINATION_VALUE_0_05 = 5,
			   DENOMINATION_CODE0_02 = 14, DENOMINATION_VALUE_0_02 = 2,
			   DENOMINATION_CODE0_01 = 15, DENOMINATION_VALUE_0_01 = 1;

			   
			   			   
parameter  DENOMINATION_AMOUNT_500 = 100,
		   DENOMINATION_AMOUNT_200 = 100,
		   DENOMINATION_AMOUNT_100 = 100,
		   DENOMINATION_AMOUNT_50  = 100,
		   DENOMINATION_AMOUNT_20  = 100,
		   DENOMINATION_AMOUNT_10  = 100,
		   DENOMINATION_AMOUNT_5   = 100,
		   DENOMINATION_AMOUNT_2   = 100,
		   DENOMINATION_AMOUNT_1   = 100,
		   DENOMINATION_AMOUNT0_50 = 100,
		   DENOMINATION_AMOUNT0_25 = 100,
		   DENOMINATION_AMOUNT0_10 = 100,
		   DENOMINATION_AMOUNT0_05 = 100,
		   DENOMINATION_AMOUNT0_02 = 100,
		   DENOMINATION_AMOUNT0_01 = 100;

		   
localparam 		CHOOSE_PRODUCT 	= 	0,
				ENTER_MONEY		= 	1,
				GIVE_PRODUCT 	= 	2,
				GIVE_CHANGE 	= 	3;

input 				i_clk;
input				i_rst_n;
input 		[3:0]	i_money;
input 				i_money_valid;
input 		[3:0]	i_product_code;
input 				i_buy;
input 				i_product_ready;

output 	reg [3:0]	o_product_code;
output 	reg 		o_product_valid;
output 	reg			o_busy;
output 	reg	[3:0]	o_change_denomination_code;
output 	reg			o_change_valid;
output 	reg 		o_no_change;

reg 		[1:0]  state, next_state;
				
reg         [19:0] wallet_r;
reg         [19:0] product_price_r;
reg signed  [19:0] change_r;				
				
reg         [15:0] denom_amount_500,
                   denom_amount_200, 	
                   denom_amount_100, 	
                   denom_amount_50, 		
                   denom_amount_20, 		
                   denom_amount_10, 	
                   denom_amount_5, 		
                   denom_amount_2, 		
                   denom_amount_1,	
                   denom_amount0_50,		
                   denom_amount0_25, 	
                   denom_amount0_10,	
                   denom_amount0_05, 	
                   denom_amount0_02, 	
                   denom_amount0_01;	
		  
		  
always @(posedge i_clk, negedge i_rst_n)
	if(!i_rst_n)
		begin
		
			wallet_r 			<= {20{1'b0}};
			product_price_r		<= {20{1'b0}};
			change_r			<= {20{1'b0}};
			
			denom_amount_500	<= 	DENOMINATION_AMOUNT_500;
			denom_amount_200	<= 	DENOMINATION_AMOUNT_200;
			denom_amount_100	<= 	DENOMINATION_AMOUNT_100; 	
			denom_amount_50 	<= 	DENOMINATION_AMOUNT_50;		
			denom_amount_20 	<= 	DENOMINATION_AMOUNT_20;
			denom_amount_10 	<= 	DENOMINATION_AMOUNT_10;
			denom_amount_5 		<= 	DENOMINATION_AMOUNT_5;
			denom_amount_2 		<= 	DENOMINATION_AMOUNT_2;
			denom_amount_1		<= 	DENOMINATION_AMOUNT_1;
			denom_amount0_50	<= 	DENOMINATION_AMOUNT0_50;	
			denom_amount0_25	<= 	DENOMINATION_AMOUNT0_25; 	
			denom_amount0_10	<= 	DENOMINATION_AMOUNT0_10;
			denom_amount0_05	<= 	DENOMINATION_AMOUNT0_05; 	
			denom_amount0_02	<= 	DENOMINATION_AMOUNT0_02; 	
			denom_amount0_01	<= 	DENOMINATION_AMOUNT0_01;

			o_product_code 		<= {4{1'b0}};
			o_product_valid 	<= 1'b0;
			o_busy 				<= 1'b0;
			o_change_denomination_code		<= {4{1'b0}};
			o_change_valid 		<= 1'b0;
			o_no_change 		<= 1'b0;

		end 
	else 
		begin
		
            o_product_valid     <= 1'b0;
            o_busy              <= 1'b0;
            o_change_denomination_code       <= {4{1'b0}};
            o_change_valid      <= 1'b0;
            o_no_change         <= 1'b0;

			case(state)
				CHOOSE_PRODUCT:
								begin
									o_product_code <= i_product_code;
                                    case(i_product_code)
                                    
                                        ESPRESSO:     product_price_r  <= PRICE_PROD_ONE;
                                        AMERICANO:    product_price_r  <= PRICE_PROD_TWO;
                                        LATTE:        product_price_r  <= PRICE_PROD_THREE;
                                        TEA:          product_price_r  <= PRICE_PROD_FOUR;
                                        MILK:         product_price_r  <= PRICE_PROD_FIVE;
                                        CHOCOLATE:    product_price_r  <= PRICE_PROD_SIX;
                                        NUTS:         product_price_r  <= PRICE_PROD_SEVEN;
                                        SNICKERS:     product_price_r  <= PRICE_PROD_EIGHT;     
                                    
                                    endcase
								end

				ENTER_MONEY:
								begin
                                    if (wallet_r < product_price_r)    //               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
                                        begin
                                            if(i_money_valid) 
                                                begin
                                                    case(i_money)
                                                    
                                                               DENOMINATION_CODE_500: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_500;
                                                                                          denom_amount_500 <= denom_amount_500 + 1;
                                                                                      end
                                                               DENOMINATION_CODE_200: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_200;
                                                                                          denom_amount_200 <= denom_amount_200 + 1;
                                                                                      end
                                                               DENOMINATION_CODE_100: 
                                                                                      begin
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_100 ;
                                                                                          denom_amount_100 <= denom_amount_100 + 1;
                                                                                      end
                                                               DENOMINATION_CODE_50:
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_50  ;                           
                                                                                          denom_amount_50  <= denom_amount_50 + 1;
                                                                                      end
                                                               DENOMINATION_CODE_20: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_20  ;                           
                                                                                          denom_amount_20  <= denom_amount_20 + 1;
                                                                                      end
                                                               DENOMINATION_CODE_10: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_10  ;                           
                                                                                          denom_amount_10  <= denom_amount_10 + 1;
                                                                                      end
                                                               DENOMINATION_CODE_5: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_5   ;                       
                                                                                          denom_amount_5   <= denom_amount_5 + 1;
                                                                                      end
                                                               DENOMINATION_CODE_2: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_2   ;                       
                                                                                          denom_amount_2   <= denom_amount_2 + 1;
                                                                                      end
                                                               DENOMINATION_CODE_1  : 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_1   ;                       
                                                                                          denom_amount_1   <= denom_amount_1 + 1;
                                                                                      end
                                                               DENOMINATION_CODE0_50: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_0_50;                           
                                                                                          denom_amount0_50 <= denom_amount0_50 + 1;
                                                                                      end
                                                               DENOMINATION_CODE0_25: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_0_25;                       
                                                                                          denom_amount0_25 <= denom_amount0_25 + 1;
                                                                                      end
                                                               DENOMINATION_CODE0_10: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_0_10;                       
                                                                                          denom_amount0_10 <= denom_amount0_10 + 1;
                                                                                      end
                                                               DENOMINATION_CODE0_05: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_0_05;                   
                                                                                          denom_amount0_05 <= denom_amount0_05 + 1;
                                                                                      end
                                                               DENOMINATION_CODE0_02: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_0_02;                   
                                                                                          denom_amount0_02 <= denom_amount0_02 + 1;
                                                                                      end
                                                               DENOMINATION_CODE0_01: 
                                                                                      begin 
                                                                                          wallet_r         <= wallet_r + DENOMINATION_VALUE_0_01;        
                                                                                          denom_amount0_01 <= denom_amount0_01 +  1;
                                                                                      end
                                                    endcase
                                                end
                                        end
                                 end
				
				GIVE_PRODUCT:
                                begin
                                
                                    change_r        <= wallet_r - product_price_r;
                                    o_product_valid <= 1;
                                    o_busy          <= 1;
                                
                                end
				
				GIVE_CHANGE:
                                begin
                                
                                    o_busy   <= 1;
                                    wallet_r <= 0;
                                    
                                    case(1'b1)
                                    
                                        (denom_amount_200 != 0) && ((change_r - DENOMINATION_VALUE_200) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE_200;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_200;
                                                                                                                    denom_amount_200 <= denom_amount_200 - 1;
                                                                                                                
                                                                                                                end

                                        (denom_amount_100 != 0) && ((change_r - DENOMINATION_VALUE_100) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE_100;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_100;
                                                                                                                    denom_amount_100 <= denom_amount_100 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount_50 != 0)  && ((change_r - DENOMINATION_VALUE_50) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE_50;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_50;
                                                                                                                    denom_amount_50  <= denom_amount_50 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                         (denom_amount_20 != 0) && ((change_r - DENOMINATION_VALUE_20) >= 0): 
                                         
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE_20;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_20;
                                                                                                                    denom_amount_20  <= denom_amount_20 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount_10 != 0)  && ((change_r - DENOMINATION_VALUE_10) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE_10;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_10;
                                                                                                                    denom_amount_10  <= denom_amount_10 - 1;
                                                                                        
                                                                                                                end
                                                                                                                
                                        (denom_amount_5 != 0)   && ((change_r - DENOMINATION_VALUE_5) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE_5;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_5;
                                                                                                                    denom_amount_5   <= denom_amount_5 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount_2 != 0)   && ((change_r - DENOMINATION_VALUE_2) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE_2;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_2;
                                                                                                                    denom_amount_2   <= denom_amount_2 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount_1 != 0)   && ((change_r - DENOMINATION_VALUE_1) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE_1;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_1;
                                                                                                                    denom_amount_1   <= denom_amount_1 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount0_50 != 0) && ((change_r - DENOMINATION_VALUE_0_50) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE0_50;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_0_50;
                                                                                                                    denom_amount0_50 <= denom_amount0_50 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount0_25 != 0) && ((change_r - DENOMINATION_VALUE_0_25) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE0_25;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_0_25;
                                                                                                                    denom_amount0_25 <= denom_amount0_25 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount0_10 != 0) && ((change_r - DENOMINATION_VALUE_0_10) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE0_10;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_0_10;
                                                                                                                    denom_amount0_10 <= denom_amount0_10 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount0_05 != 0) && ((change_r - DENOMINATION_VALUE_0_05) >= 0):
                                         
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE0_05;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_0_05;
                                                                                                                    denom_amount0_05 <= denom_amount0_05 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount0_02 != 0) && ((change_r - DENOMINATION_VALUE_0_02) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE0_02;
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_0_02;
                                                                                                                    denom_amount0_02 <= denom_amount0_02 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        (denom_amount0_01 != 0) && ((change_r - DENOMINATION_VALUE_0_01) >= 0): 
                                        
                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_denomination_code    <= DENOMINATION_CODE0_01;
                                                                                                                    o_change_valid   <= 1;    
                                                                                                                    change_r         <= change_r - DENOMINATION_VALUE_0_01;
                                                                                                                    denom_amount0_01 <= denom_amount0_01 - 1;
                                                                                                                
                                                                                                                end
                                                                                                                
                                        default: 

                                                                                                                begin
                                                                                                                
                                                                                                                    o_change_valid   <= 1;
                                                                                                                    o_no_change      <= 1;
                                                                                                                
                                                                                                                end
                                            
                                    endcase
                                
                                end
					
			endcase	
	
		end 


		  
always @*
	case (state)
		CHOOSE_PRODUCT:
		
		                  begin
						  
		                      if(i_buy)
		                          next_state = ENTER_MONEY;
							  else
								  next_state = CHOOSE_PRODUCT;
								  
		                  end
						  
		ENTER_MONEY:
		
		                  begin
						  
							  if(wallet_r >= product_price_r)
		                          next_state = GIVE_PRODUCT;
							  else
								  next_state = ENTER_MONEY;
							
                          end		
						  
		GIVE_PRODUCT:
		
		                  begin
						  
							  if(i_product_ready)
		                          next_state = GIVE_CHANGE;
							  else
								  next_state = GIVE_PRODUCT;
							
                          end		
						  
		GIVE_CHANGE:
		
		                  begin
						  
							  if(o_no_change || !change_r)
		                          next_state = CHOOSE_PRODUCT;
							  else
								  next_state = GIVE_CHANGE;
							
                          end		
						  
		default:		
						  begin
							
							next_state = CHOOSE_PRODUCT;
							
						  end
	endcase
				


		  
always @(posedge i_clk, negedge i_rst_n)
	if(!i_rst_n)
		state <= CHOOSE_PRODUCT;
	else
		state <= next_state;

endmodule						
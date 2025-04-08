module WaveGenerator (
    input wire clk,             // Horloge système
    input wire rst_n,           // Reset actif bas
    input wire enable,          // Validation On/Off
    input wire [31:0] t_rise,   // Durée de la montée
    input wire [31:0] t_high,   // Durée du plateau haut
    input wire [31:0] t_fall,   // Durée de la descente
    input wire [31:0] t_low,    // Durée du plateau bas
    output reg [3:0] wave_out   // Signal de sortie 4 bits
);

    reg [31:0] counter; // Mesure de la durée des 4 étapes
    reg [31:0] wait_counter; // Mesure le temps entre deux incréments / décréments
    reg [1:0] state;  // 4 états : 00 (montée), 01 (plateau haut), 10 (descente), 11 (plateau bas)
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 32'd0;
            wait_counter <= 32'd0;
            wave_out <= 4'd0;
            state <= 2'b00;
        end 
        else if(enable == 1'b0) wave_out <= 4'd0;
        else begin
            case (state)
                2'b00: begin  // Montée
                    if (counter == 32'd0) wait_counter <= t_rise >> 4; // Division par 16 via décalage
                    if (counter < 32'd15) begin
                        if (wait_counter == 32'd0) begin
                            wave_out <= wave_out + 4'd1;
                            wait_counter <= t_rise >> 4;
                            counter <= counter + 32'd1;
                        end else begin
                            wait_counter <= wait_counter - 1;
                        end
                    end else begin
                        counter <= 32'd0;
                        state <= 2'b01;
                    end
                end
                2'b01: begin  // Plateau haut
                    wave_out <= 4'b1111;
                    if (counter < t_high) begin
                        counter <= counter + 32'd1;
                    end else begin
                        counter <= 32'd0;
                        state <= 2'b10;
                    end
                end
                2'b10: begin  // Descente
                    if (counter == 4'd0) wait_counter <= t_fall >> 4;
                    if (counter < 4'd15) begin
                        if (wait_counter == 32'd0) begin
                            wave_out <= wave_out - 4'd1;
                            wait_counter <= t_fall >> 4;
                            counter <= counter + 32'd1;
                        end else begin
                            wait_counter <= wait_counter - 32'd1;
                        end
                    end else begin
                        counter <= 32'd0;
                        state <= 2'b11;
                    end
                end
                2'b11: begin  // Plateau bas
                    wave_out <= 4'b0000;
                    if (counter < t_low) begin
                        counter <= counter + 32'd1;
                    end else begin
                        counter <= 32'd0;
                        state <= 2'b00;
                    end
                end
            endcase
        end
    end
endmodule

#include <stdio.h>
//#include <>

int main(){
char number;

printf("\nEnter number of ports: ");
scanf("%d", &number);

FILE *f;
char name[20];

sprintf(name, "file%d.txt", number); 
f = fopen(name, "w");
if(f == NULL){
	printf("Error opening file!\n");
	return 1;
}

char *text =" typedef enum int unsigned{IDLE,";
fprintf(f, text);
for (int i = 1; i <= number; i++)
{
	if(i == number) {
	fprintf(f, "I%d ", i);	
	}
	else
	fprintf(f, "I%d, ", i);
}
fprintf(f, "} state_t;\n");


fprintf(f, " \n\
state_t state, next;\n");

fprintf(f, "always_comb begin \n\
	next = state;\n\
	decision_ready = 0;\n\
	first_iteration = '0;\n\
	case (state)\n\
		IDLE: begin\n\
			if(start) begin\n\
				next = I1;\n\
				end\n\
			else\n\
				next = IDLE;\n\
			decision_ready = 1;\n\
		end\n\
		I1: begin\n\
				next = I2;\n\
				first_iteration = '1;\n\
		end\n");


char buf[4];
for (int i = 2; i <= number; i++)
{
	sprintf(buf, "I%d", i+1);
	fprintf(f, "I%d: next = %s;\n", i, i == (number)? "IDLE": buf);
}


fprintf(f, "	endcase\n\
end\n");
fclose(f);
return 0;
}
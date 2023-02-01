#include <iostream>
#include <cmath>
#include <iostream>
#include <cmath>
#include <functional>
#include <ctime>
#include <chrono>




using namespace std;

//function to round the result to two decimal places
double apr(double x){
  double d=round(x*100);
  x=d/100;
  return x;
}

//a function that calculates the integral of a polynomial function of the form f(x)=a*x^n+b*x^(n-1)+...+y*x+z

__global__ void integral(double x_1, double x_2, double d,double *results){
  
  const int s=2; //polynomial degree
  double w[s+1]={1,1,1}; //array of polynomial coefficients {a,b,c,...}
  double y1=0, y2=0;

  int N=(x_2-x_1)/d; //number of steps
  int t = blockIdx.x * blockDim.x + threadIdx.x; //variable to check if we are not going out of range
  if (t<N)
  {
   for (int i=0; i<s+1; i++){
       y1+=pow(x_1+d*t,i)*w[s-i]; 
       y2+=pow(x_1+d*(t+1),i)*w[s-i]; 
   }
   results[t]=(y1+y2)*0.5*d; //area under a trapezoid with bases y1 and y2 and height d
  }
}

int main() {
  
  double x_1=-5.,x_2=5.;//integration limits
  double d=0.001; //length of step
  int N=(x_2-x_1)/d; //number of steps

  
  double *result; //array of results
  double r=0.; //result
  size_t size = N*sizeof(double);
  cudaMallocManaged(&result, size);

  int threads_per_block = 256;
  int number_of_blocks = (N / threads_per_block) + 1;

  //execution time
  
  //mirzenie czasu juhuu
  const int n=1000;
  double t_time[n]={0};
  double mean=0;

  chrono::steady_clock::time_point s_r1;
  chrono::steady_clock::time_point e_r1;
  
  int m=0;
  for (int i=0; i<n; i++){
    //execution time
    s_r1 = chrono::steady_clock::now();
  
    integral<<< number_of_blocks, threads_per_block >>>(x_1, x_2, d, result);
    cudaDeviceSynchronize();
    
    e_r1 = chrono::steady_clock::now();

    t_time[i]=chrono::duration_cast<chrono::microseconds> (e_r1 - s_r1).count();
    // wyswietlanie otrzymanych czasow
    cout<<i+1<<". "<<t_time[i]<<endl;
    //filtrowanie anomalnie du¿ych wyników
    if (t_time[i]<500){
      mean+=t_time[i];
      m++;
    }
  }

  mean=mean/m;

  cout<<"Mean: "<<mean<<endl;

  for (int i=0; i<N; i++){
      r+=result[i];
  }
  r=apr(r);
   
  
  //result
  

  cout<<"Integral of a polynomial function in limits ("<<x_1<<","<<x_2<<") equals = "<<r<<endl;
  //cout<<"Execution time: "<< chrono::duration_cast<chrono::microseconds> (e_r1 - s_r1).count() << " us"<<endl<<endl;
 

  cudaFree(result);
}

#include <iostream>
#include <cmath>
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
void integral(double x_1, double x_2, double d, double *results){

  const int s=2; //polynomial degree
  double w[s+1]={1,1,1}; //array of polynomial coefficients {a,b,c,...}

  int N=(x_2-x_1)/d; //number of steps
  for (int t=0; t<N; t++)
  {
    double y1=0, y2=0;
    for (int i=0; i<s+1; i++){
      y1+=pow(x_1+d*t,i)*w[s-i]; //function value for x
      y2+=pow(x_1+d*(t+1),i)*w[s-i]; //function value for x+d
    }
    results[t]=(y1+y2)*0.5*d; //area under a trapezoid with bases y1 and y2 and height d
  }
}

int main() {
 
  double x_1=-5,x_2=5; //integration limits
  double d=0.001; //length of step
  int N=(x_2-x_1)/d; //number of steps
  
  
  double *result; //array of results
  double r=0.; //result
  size_t size = N*sizeof(double);
  result = (double*)malloc(size);

  //measuring time of the function
  const int n=1000;
  double t_time[n]={0};
  double mean=0;

  chrono::steady_clock::time_point s_r1;
  chrono::steady_clock::time_point e_r1;

  for (int i=0; i<n; i++){
    //execution time
    s_r1 = chrono::steady_clock::now();
  
    integral(x_1, x_2, d, result);
    
    e_r1 = chrono::steady_clock::now();

    t_time[i]=chrono::duration_cast<chrono::microseconds> (e_r1 - s_r1).count();
    // wyswietlanie otrzymanych czasow
    cout<<i+1<<". "<<t_time[i]<<endl;
    //filtrowanie anomalnie dużych wyników
    if (t_time[i]<1000){
      mean+=t_time[i];
    }
  }

  mean=mean/n;
  cout<<"Mean: "<<mean<<endl;

  
  //end of measurment

  //summing up
  for (int j=0;j<N;j++){
    r+=result[j];
  }
  r=apr(r);
  
  //result
  cout<<"Integral of a polynomial function in limits ("<<x_1<<","<<x_2<<") equals = "<<r<<endl;
  
  free(result);
}
# Linear Optimization & Radviz - MATLAB

## Reflection

Genetic algorithms are a pretty interesting way to solve both linear and nonlinear optimization problems. In this project, I simply applied a standard genetic algorithm to a linear problem. In the future, I plan to dive deeper into modifying the control parameters of the genetic algorithm.

As far as Radviz, is it a complete solution to visualizing multidimensional problem spaces? No.

When collapsing multidimensional space to just two dimensions, there are clearly issues with multiple values of **X** being mapped to the same (x,y) point. In 4 dimensions, this isn't much of a problem - especially for simple visualization. However, the problem worsens quickly as dimensionality increases.

## Table of Contents

 - [Trailmix Problem Example](#Trail-Mix-Problem-Example)
	 - [Problem Definition](#Problem-Definition)
		 - [Trail Mix Ingredients](#Trail-Mix-Ingredients)
		 - [Requirements](#Requirements)
		 - [Given Information](#Given-Information)
		 - [Goal](#Goal)
	 - [Optimization Code](#Optimization-Code)
		 - [Setup](#Setup)
			 - [Set Bounds](#Set-Bounds)
			 - [Linear Constraints](#Linear-Constraints)
			 - [Setup Custom Output Function](#Setup-Custom-Output-Function)
			 - [Run the Genetic Algorithm](#Run-the-Genetic-Algorithm)
			 - [Function Definitions](#Function-Definitions)
		 - [Looping the Optimization Function](#Looping-the-Optimization-Function)
- [Implementing Radviz](#Implementing-Radviz)
	- [Concept](#Concept)
	- [Assumptions](#Assumptions)
	- [Placing Anchors](#Placing-Anchors)
	- [Calculating Equilibrium](#Calculating-Equilibrium)
	- [Understanding the Output](#Understanding-the-Output)

## Trail Mix Problem Example

### Problem Definition

#### Trail Mix Ingredients
- Almonds
- Walnuts
- Cashew
- Raisins
- Peanuts

#### Requirements
- 45% Protein by Weight
- 30% Carbohydrates by Weight
- 25% Fat by Weight

#### Given Information
|  | Almonds | Walnuts | Cashew | Raisins | Peanuts
|:----:|:----:|:----:|:----:|:----:|:----:|
| **wt% Protein** | 55 | 45 | 40 | 10 | 25
| **wt% Carbs** | 15 | 15 | 45 | 65 | 50 
| **wt% Fat** | 30 | 40 | 15| 25 | 25
| **Cost/Lb $** | 6 | 8 | 7 | 2 | 3
#### Goal
>Minimize the Cost of 1 Lb of This Trail Mix

## Optimization Code
### Setup

The weight percents (as decimals) of our five ingredients represent the five variables X1 through X5 which make up **X**. 
    
    %Number of variables
    n = 5;
    
#### Set Bounds

The lower and upper bounds are inclusive in MATLAB. I set the bounds as [0.01,0.99] to make sure all of the ingredients are included.

    %Set all bounds to (0.01,0.99)
    LB = (zeros(1,n)+1)*0.01;
    UB = (zeros(1,n)+1)*0.99;

If you want to impose individual bounds (like a 25% walnut minimum), you can manually assign bound vectors.
#### Linear Constraints

These come from the linear equation Ax=b defined by [Given Information (A)](#Given-Information) and [Requirements (b)](#Requirements).  The last row represents the constraint that the sum of X1 to Xn must equal 1 since X values represent weight fractions.

    %Define Linear Constraints
    A = [55 45 40 10 25
         15 15 45 65 50
         30 40 15 25 25
          1  1  1  1  1];
 
    b = [45
         30
         25
          1];

#### Setup Custom Output Function

This output function stores the generation, the values of **X** for each member of each generation and the value of f(**X**).

    %Setup output function
    options = optimoptions('ga','OutputFcn',@outfun);

#### Run the Genetic Algorithm

    [optData.xSol, optData.minCost] = ga(@costFunction, n, [], [], A, b, LB, UB, [], options);

### Function Definitions
Custom Output Function

This populates @history.popData which contain rows [ Generation, f(**X**), X1, ..., Xn ]

    %Define Output Function
    function [state,options,optchanged] = outfun(options,state,flag)
        persistent vals;
        
        optchanged = false;

        switch flag
            case 'init'
                
            case 'iter'
                
                % Default population size is 50 for Xn < 6
                temp = (zeros(50,1)+1)*state.Generation;
                vals = [vals; temp state.Score state.Population];

            case 'done'
                
                optData.popData = vals;
                vals = [];
                
            otherwise
        end
    end

Cost Function

    function y = costFunction(x)
        y = 6 * x(1) + 8* x(2) + 7 * x(3) + 2 * x(4) + 3 * x(5);
    end

### Looping the Optimization Function

Since genetic algorithms are partially based on random occurrences, it can be helpful to run the optimization several times. 

    clc; clear;

	runs = 1000;
	n = 5;
	allSol = [];

	for i = 1:runs
	    history = Optimize;
	    allSol = [allSol; history.popData];
	end

	writematrix(allSol,'ExcelFile.xlsx','Sheet', 1);


## Implementing Radviz

#### Concept
For a vector **X** of n variables, all values X1 to Xn can be mapped inside of the unit circle given that
- X1 through Xn are normalized
- X1 through Xn are spaced at equal angles around the circumference
- X1 through Xn act as fixed anchors for springs with k values of their normalized values
- The point (x,y) represents one **X** with the 'springs' at equlilbrium

![image](https://github.com/jobertol/LinOptRadViz-MATLAB/blob/master/Images/Equilibrium.png)

#### Assumptions
 - Reads an Excel File (.xlsx) 
 - For a function f(**X**) of n variables
	 - Column 1 Represents Generation
	 - Column 2 Represents f(**X**)
	 - Columns 3:n+2 represent X1 to Xn

#### Placing Anchors
I like my figures to be oriented with the +y axis, so I start at an angle of Pi/2 with respect to +x.

The angle phi between each variable on the circumference is equal to 2Pi/n.

![image](https://github.com/jobertol/OptimizationProjects-MATLAB/blob/master/Images/Angles.png)

To compute the (x,y) positions of each anchor we use the following code:

    anchors = zeros(n,2);
    theta = pi/2;

    for i = 1:n
        anchors(i,1) = cos(theta);
        anchors(i,2) = sin(theta);
        theta = theta + phi;
    end

The anchors are stored in an n by 2 matrix with column 1 representing x positions and column 2 representing y positions.

#### Calculating Equilibrium
For my fellow engineers, this will be pretty simple. For anyone else, these are some basic concepts.
- Ideal Springs Exert Force Proportional to Their Elongation (F=kx)
- 2D Static Equilibrium Occurs When All the Forces in Each Direction Sum to Zero
	- The Sum of Forces in the X Direction = 0  
	- The Sum of Forces in the Y Direction = 0  

For each **X**, we need to calculate the x and y distances between each anchor and the equilibrium point. 

We have to solve for the position of our equilibrium point which will be represented by (x,y).

The sum of the forces in the X direction will be
> ![equation](https://render.githubusercontent.com/render/math?math=X_1(a_{1x}-x)+%2B+X_2(a_{2x}-x)+...+%2B+X_n(a_{nx}-x)=0)

> ![equation](https://render.githubusercontent.com/render/math?math=Y_1(a_{1y}-y)+%2B+Y_2(a_{2y}-y)+...+%2B+Y_n(a_{ny}-y)=0)

With some simple algebra, the equation simplifies to

>![equation](https://render.githubusercontent.com/render/math?math=\Sigma+X_i+a_{ix}+-+x+\Sigma+X_i+=0)

with the solution

>![equation](https://render.githubusercontent.com/render/math?math=x=\Sigma+X_i+a_{ix}+/+\Sigma+X_i)

Similarly, for y
>![equation](https://render.githubusercontent.com/render/math?math=y=\Sigma+Y_i+a_{iy}+/+\Sigma+Y_i)

This is expressed with the following code

    points = zeros(length,3);

    for i = 1:length
        sumXi = 0;
        sumXiaix = 0;
        sumXiaiy = 0;

        for j = 1:n
            sumXi = sumXi + radVizData(i,j);
            sumXiaix = sumXiaix + radVizData(i,j)*anchors(j,1);
            sumXiaiy = sumXiaiy + radVizData(i,j)*anchors(j,2);
        end

        points(i, 1) = sumXiaix/sumXi;
        points(i, 2) = sumXiaiy/sumXi;
        points(i, 3) = data(i,zIndex);

    end

#### Understanding the Output

For our trail mix example, here are some plots

In the image below, the z axis plots the generation number. The plot shows the convergence of the 50 members of each generation at the top of the plot from the diversified starting values at the bottom.
![image](https://github.com/jobertol/OptimizationProjects-MATLAB/blob/master/Images/RadVizGen.jpg)

In this image, the z axis plots the value of f(**X**). The low density of red points shows that there are few **X** values that are high cost. In the mid-section of the plot, the spread widens as more varied combinations are tried. Finally, the data converges to a minimum at the bottom which represents the solution of our problem.
![image](https://github.com/jobertol/OptimizationProjects-MATLAB/blob/master/Images/RadVizFx.jpg)

clear all
clc
close all

height = 0.6096;
%drawbar length: 1.8923 meters
y1 = 0:0.0001:1.8923
x1 = zeros(size(y1));
z1 = height*ones(size(y1));
V1=[x1(:) y1(:) z1(:)];
%implement face to ground (tire contacts): 2.066 meters
y2 = 1.8922:0.0001:(1.8923+2.066);
x2 = zeros(size(y2));
z2 = height*ones(size(y2));
V2=[x2(:) y2(:) z2(:)];
%total disker width: 4.7244 meters
x3 = (-1.524/2):0.0001:(1.524/2);
y3 = (1.8923+2.066)*ones(size(x3));
z3 = height*ones(size(y3))
V3=[x3(:) y3(:) z3(:)];
%hitch length: 0.3048 meters
x4 = -0.3903:0.0001:0;
y4 = -0.3903:0.0001:0;
z4 = height*ones(size(y4));
V4=[x4(:) y4(:) z4(:)];
%height: 0.6096 meters
%width between tires: 1.524 meters

%Rotate
gamma = -pi/4;
r1 = [cos(gamma) 0 sin(gamma) 0];
r2 = [0 1 0 0];
r3 = [-sin(gamma) 0 cos(gamma) 0];
r4 = [0 0 0 1];
R1 = [r1; r2; r3; r4;]

%Translate back

%Translate
t1 = [1 0 0 1.524/2];
t2 = [0 1 0 -(1.8923+2.066)];
t3 = [0 0 1 -height];
t4 = [0 0 0 1];

t_front = [t1;t2;t3;t4];

%Translate back
t5 = [1 0 0 -1.524/2];
t6 = [0 1 0 (1.8923+2.066)];
t7 = [0 0 1 height];
t8 = [0 0 0 1];

t_back = [t5;t6;t7;t8]

T1 = t_back * R1 * t_front 

figure;
plot3(V1(:,1),V1(:,2),V1(:,3),'k.-','MarkerSize',10);  hold on;
plot3(V2(:,1),V2(:,2),V2(:,3),'g.-','MarkerSize',10)
plot3(V3(:,1),V3(:,2),V3(:,3),'r.-','MarkerSize',10)
plot3(V4(:,1),V4(:,2),V4(:,3),'b.-','MarkerSize',10)

plot3(V1(:,1),V1(:,2),zeros(size(V1(:,1))),'g.-','MarkerSize',10);  hold on;
plot3(V2(:,1),V2(:,2),zeros(size(V2(:,1))),'g.-','MarkerSize',10)
plot3(V3(:,1),V3(:,2),zeros(size(V3(:,1))),'g.-','MarkerSize',10)
plot3(V4(:,1),V4(:,2),zeros(size(V4(:,1))),'g.-','MarkerSize',10)

hcoords1 = [V1 ones(size(y1,2),1)];
tf1 = (T1 *hcoords1')';
hcoords2 = [V2 ones(size(y2,2),1)];
tf2 = (T1 *hcoords2')';
hcoords3 = [V3 ones(size(y3,2),1)]
tf3 = (T1 *hcoords3')';
hcoords4 = [V4 ones(size(y4,2),1)]
tf4 = (T1 *hcoords4')';

plot3(tf1(:,1),tf1(:,2),tf1(:,3),'k.-','MarkerSize',10)
plot3(tf2(:,1),tf2(:,2),tf2(:,3),'k.-','MarkerSize',10)
plot3(tf3(:,1),tf3(:,2),tf3(:,3),'k.-','MarkerSize',10)
plot3(tf4(:,1),tf4(:,2),tf4(:,3),'k.-','MarkerSize',10)

plot3(tf1(:,1),tf1(:,2),zeros(size(tf1(:,2))),'r.-','MarkerSize',10)
plot3(tf2(:,1),tf2(:,2),zeros(size(tf2(:,2))),'r.-','MarkerSize',10)
plot3(tf3(:,1),tf3(:,2),zeros(size(tf3(:,2))),'r.-','MarkerSize',10)
plot3(tf4(:,1),tf4(:,2),zeros(size(tf4(:,2))),'r.-','MarkerSize',10)

xlabel('X');
ylabel('Y');
zlabel('Z');

delta_gamma = 0:1:90
results = zeros(size(delta_gamma, 2), 2);
for i = 1:size(delta_gamma,2)
    gamma = delta_gamma(i)
    r1 = [cosd(gamma) 0 sind(gamma) 0];
    r2 = [0 1 0 0];
    r3 = [-sind(gamma) 0 cosd(gamma) 0];
    r4 = [0 0 0 1];
    R1 = [r1; r2; r3; r4;];
    
    T1 = t_back * R1 * t_front;
    
    hcoords1 = [V1 ones(size(y1,2),1)];
    tf1 = (T1 *hcoords1')';
    hcoords2 = [V2 ones(size(y2,2),1)];
    tf2 = (T1 *hcoords2')';
    hcoords3 = [V3 ones(size(y3,2),1)];
    tf3 = (T1 *hcoords3')';
    hcoords4 = [V4 ones(size(y4,2),1)];
    tf4 = (T1 *hcoords4')';
    
    pt1 = tf1(size(tf4,1), :);
    pt2 = tf4(1, :);
    pt3 = tf4(size(tf4,1),:);
    
    vec1 = [pt1(1), pt1(2), 0] - [pt3(1), pt3(2), 0];
    vec2 = [pt2(1), pt2(2), 0] - [pt3(1), pt3(2), 0];
    
    onedof_theta = 180 - rad2deg(atan2(norm(cross(vec1,vec2)), dot(vec1, vec2)))
    error = 45 - onedof_theta
    results(i,:) = [gamma, error];
    
end

axis equal; view(3); axis tight; grid on;

figure(2)
plot(results(:,1), results(:,2))
title('One Degree Approximation Error vs. Roll');
xlabel('Roll (degrees)');
ylabel('Yaw Error (degrees)');
grid on










%Testing pnp algorithm on example setup
%goal: determine how much pixel errpr in camera pixel frame translates into
% pose yaw error

%First setup local coordinate system for markers
%assume perfect camera calibration
%test first with 0 r,p,y and then try at 45 degree postition
%setting up transforms will be tough at first, take care of this

%resolution: 3264x2464
%focal length?
%use example calibration dataset parameters? Or come up with hypothetical?

%example of using a rigid transform. Maybe use this for setting up
%extrinsic?

%function for pnp: estimateWorldCameraPose
%except uses p3p algorithm. minimum of 4 point correspondences needed

%Next todo:
%Test actual PNP
%Try matching camera coordinates with the coordinates in plot3 to see if it
%gets fixed
%Figure out why I needed to transpose the rotation matrix in tform
%figure out what accuracy of the pnp alg is by reprojecting the points
%using extrinsics looks like

%MAKE SURE TO LOAD "pnp_testing_workspace.mat" BEFORE RUNNING SCRIPT FOR THE FIRST TIME!!!


close all

%rotation order: RzRyRxv
%gamma = 180;
gamma = 0;
rotz = [ cosd(gamma) -sind(gamma) 0; ...
        sind(gamma) cosd(gamma) 0; ...
        0 0 1];

%beta = 270;
beta = 270;
roty = [ cosd(beta) 0  sind(beta); ...
        0 1 0; ...
        -sind(beta) 0 cosd(beta)];

%alpha = 90;
alpha = 90;
rotx = [1 0 0; ...
        0 cosd(alpha) -sind(alpha); ...
        0 sind(alpha) cosd(alpha)];

horiz = 0; %X axis
vert =  0; %Y axis
depth = 0; %Z axis
trans = [horiz vert depth];

rotationMat = rotz*roty*rotx;
tform = rigid3d(rotationMat, trans);

%plot camera
figure(1)
cam = plotCamera('AbsolutePose',tform,'Opacity',0,'AxesVisible',1)
hold on
grid on
axis equal
axis manual
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('Z (mm)');
xlim([-5000 5000])
ylim([-5000 5000])
zlim([-1000 1000])

%Draw the arc that the marker board rotates about
r = 5000;
theta_arc = -pi:0.01:pi;
x_arc = r*cos(theta_arc);
y_arc = r*sin(theta_arc);
plot3(x_arc, y_arc, zeros(1,numel(x_arc)));

%create transform that rotates the marker board
%use transformPointsForward function with the tform in order to move from
%marker to world frame

%rotations of marker board
gamma_board = -45;
rotz_board = [ cosd(gamma_board) -sind(gamma_board) 0; ...
        sind(gamma_board) cosd(gamma_board) 0; ...
        0 0 1];

beta_board = 0;
roty_board = [ cosd(beta_board) 0  sind(beta_board); ...
        0 1 0; ...
        -sind(beta_board) 0 cosd(beta_board)];

alpha_board = 0;
rotx_board = [1 0 0; ...
        0 cosd(alpha_board) -sind(alpha_board); ...
        0 sind(alpha_board) cosd(alpha_board)];

%translation of marker board
horiz_board = r*cosd(gamma_board); %X axis
vert_board =  r*sind(-gamma_board); %Y axis
depth_board = 0; %Z axis
trans_board = [horiz_board vert_board depth_board];

%I'll redefine the marker board coordinate system this way for testing
brdX_test = zeros(4,1);
brdY_test = [-500; 500; 250; -250];
brdZ_test = [0; 0; 500; 500];

rotationMat_board = rotz_board*roty_board*rotx_board;
tform_board = rigid3d(rotationMat_board, trans_board);

[x_out,y_out,z_out] = transformPointsForward(tform_board, brdX_test, brdY_test, brdZ_test);
plot3(x_out, y_out, z_out, 'b*');
%make blue fill between marker board corner points to make it easier to see
h1 = fill3(x_out,y_out,z_out, [0 0 1]);

hold off

%project world points to camera. This uses the intrinsics from the
%successful calibration we had in the lab
worldPts = horzcat(x_out,y_out,z_out);
figure(2)
imagePoints = worldToImage(params.Intrinsics, rotationMat',trans, worldPts);
plot(imagePoints(:,1), imagePoints(:,2), 'g*-')
hold on
%set(gca,'XDir','reverse')
set(gca,'YDir','reverse')
xlim([1 3264])
ylim([1 2464])

%Had to convert the fisheye calibration parameters to a "virtual pinhole"
%model in order to use matlab's p3p
[undistortedPoints, intrinsics1, reprojectionErrors] = undistortFisheyePoints(imagePoints, params.Intrinsics);
plot(undistortedPoints(:,1), undistortedPoints(:,2), 'r*-')
hold off

%run p3p
[worldOrientation, worldLocation, inlierIdx, status] = estimateWorldCameraPose(undistortedPoints, horzcat(brdX_test, brdY_test, brdZ_test), intrinsics1)

figure(3)

%plot the results
pcshow(horzcat(brdX_test, brdY_test, brdZ_test), ...
     'MarkerSize',300);
hold on
plotCamera('Size', 500, 'Orientation', worldOrientation, 'Location', ...
    worldLocation);

xlim([-10000 10000])
ylim([-10000 10000])
zlim([-10000 10000])
% usage: input: a: time indexes
%               b: f(t)
% output: approximate coefficient c0, c1, c2

function C_array = POLY_APPRO(a, b, order, dtau)
    A_Matrix = zeros(order);
    B_Array = zeros(order,1);
    if length(a) == 1 && length(b) == 1
        C_array(1) = b;
        return;
    end
    a= a- min(a(:));
    order_sum = zeros(order*2-1);
    for m = 1:order
        phi_m = (a.*dtau).^(m-1);
        if m <= order
            B_Array(m) = dot(phi_m,b);
        end
        order_sum(m) = sum(phi_m);
    end
    for i = 1:order
        for j= 1:order
            A_Matrix(i,j) = order_sum(i+j-1);
        end
    end
    C_array = A_Matrix\B_Array;
%     for m = 1:order
%         phi_m = (a.*dtau).^(m-1);
%         for n = 1:order
%             phi_n = (a.*dtau).^(n-1);
%             A_Matrix(m,n) =dot(phi_m, phi_n);
%         end
%         B_Array(m) = dot(phi_m,b);
%     end
%     C_array = A_Matrix\B_Array;
end
    
#inclde("extras/tk.jl")
#import Tk.*
#import Cairo.*

function life_rule(new, old)
    for j = 2:size(old,2)-1
        for i = 2:size(old,1)-1
            nc = +(old[i-1,j-1], old[i-1,j], old[i-1,j+1],
                   old[i  ,j-1],             old[i  ,j+1],
                   old[i+1,j-1], old[i+1,j], old[i+1,j+1])

            new[i-1,j-1] = (nc == 3 ? 1 :
                            nc == 2 ? old[i,j] :
                            0)
        end
    end
    new
end

function life_step(d)
    DArray(size(d),[2:nprocs()]) do I
        m, n = length(I[1]), length(I[2])

        # fetch neighborhood
        old = Array(Bool, m+2, n+2)
        old[2:end-1, 2:end-1] = d[I...]
        top   = mod(first(I[1])-2,size(d,1))+1
        bot   = mod( last(I[1])  ,size(d,1))+1
        left  = mod(first(I[2])-2,size(d,2))+1
        right = mod( last(I[2])  ,size(d,2))+1
        old[1      , 2:end-1] = d[top , I[2]]
        old[2:end-1, 1      ] = d[I[1], left]
        old[end    , 2:end-1] = d[bot , I[2]]
        old[2:end-1, end    ] = d[I[1], right]
        old[1  ,1  ] = d[top,left]
        old[end,1  ] = d[bot,left]
        old[1  ,end] = d[top,right]
        old[end,end] = d[bot,right]

        life_rule(Array(Bool, m, n), old)
    end
end

function plife(m, n)
    w = Window("parallel life", n, m)
    c = Canvas(w)
    pack(c)
    cr = cairo_context(c)

    grid = DArray(I->randbool(map(length,I)), (m, n), [2:nprocs()])
    while true
        img = convert(Array,grid) .* 0x00ffffff
        set_source_surface(cr, CairoRGBSurface(img), 0, 0)
        paint(cr)
        reveal(c)
        grid = life_step(grid)
        #sleep(0.03)
    end
end
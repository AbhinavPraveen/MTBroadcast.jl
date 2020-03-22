module MTBroadcast

export mtB,mtBcall

"""
    mtB(f,x...[; n = Threads.nthreads()])

Applies the function 'f' to the varargs 'x...' using 'n' threads and returns the output. 
"""
function mtB(f, x...; n = Threads.nthreads())
    wLength = length(x[1])
    q,r = divrem(wLength,n)
    nEls =fill(q,n-1)
    nEls[1:r] .+=1
    for i = (n-2):-1:1
        nEls[i] += nEls[i+1]
    end
    nEls = vcat(wLength, nEls, 0)
    temp = Array{Any}(undef, n)
    for i = 1:n
        temp[n-i+1] = Base.Threads.@spawn f.(view.(x, [(nEls[i+1]+1):nEls[i]])...)
    end
    return vcat(fetch.(temp)...)
end

"""
    mtBcall(f,x...[; n = Threads.nthreads()])

Assigns 'n' threads to apply the function 'f' to the varargs 'x...' and returns the generated task objects. You may wait.() or fetch.() these objects. This is significantly faster than mtB() if the task objects can be handled efficiently.
"""
function mtBcall(f, x...; n = Threads.nthreads())
    wLength = length(x[1])
    q,r = divrem(wLength,n)
    nEls =fill(q,n-1)
    nEls[1:r] .+=1
    for i = (n-2):-1:1
        nEls[i] += nEls[i+1]
    end
    nEls = vcat(wLength, nEls, 0)
    temp = Array{Task}(undef, n)
    for i = 1:n
        temp[n-i+1] = Base.Threads.@spawn f.(view.(x, [(nEls[i+1]+1):nEls[i]])...)
    end
    return temp
end


end

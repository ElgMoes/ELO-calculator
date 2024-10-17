using DataFrames
using Sqids

function create_players(players)
    function random_new_hex(player)
        config = Sqids.configure(minLength=10)
        id = Sqids.encode(config, [player, player + 1])
        return id
    end
    
    function gaussian_bell_curve(x, μ, σ)
        return exp(-((x - μ)^2) / (2 * σ^2))*players/600
    end

    μ = players/200.0
    σ = players/1000

    df = DataFrame(
        id=String[],
        score=Int64[],
        skill=Float64[],
        consistency=Float64[],
        score_history=Vector{Int64}[]
    );

    for i in 1:players
        id = random_new_hex(i)
        score = 1000
        skill = i / 100.0
        consistency = gaussian_bell_curve(skill, μ, σ)
        score_history = [score]

        push!(df, (id, score, skill, consistency, score_history))
    end
    return df
end
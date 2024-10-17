using DataFrames
using Random
using Statistics
using CSV
using ProgressMeter
include("setup.jl")

df = create_players(1500)

function average_skill(df)
    return mean(df.skill)
end

function create_groups(df, range)
    group_df = df[range, [:id, :score, :skill, :consistency, :score_history]]
    shuffle!(group_df)
    group1_df = group_df[1:5, [:id, :score, :skill, :consistency, :score_history]]
    group2_df = group_df[6:10, [:id, :score, :skill, :consistency, :score_history]]

    sort!(group1_df, [:skill])
    sort!(group2_df, [:skill])

    return group1_df, group2_df
end

function merge_dataframe!(df, df_new)
    for row in eachrow(df_new)
        idx = findfirst(x -> x == row.id, df.id)
        if idx !== nothing
            df.score[idx] = row.score
            push!(df.score_history[idx], row.score)
        end
    end
end

function play_game!(df, range, K)
    group1_df, group2_df = create_groups(df, range)

    skill1 = average_skill(group1_df)
    skill2 = average_skill(group2_df)

    E1 = 1/(1+10^((skill2-skill1)/400))
    E2 = 1/(1+10^((skill1-skill2)/400))

    if skill1 > skill2
        group1_df.score .+= round.(K*(1-E1))
        group2_df.score .+= round.(K*(0-E2))
    elseif skill1 < skill2
        group1_df.score .+= round.(K*(0-E1))
        group2_df.score .+= round.(K*(1-E2))
    end

    merge_dataframe!(df, group1_df)
    merge_dataframe!(df, group2_df)
    return df
end

function play_round!(df, rounds)
    K = rounds < 30 ? 40 : rounds < 200 ? 20 : 10
    for i in 1:(nrow(df)/10)
        range = Int(round(10*i - 9)):Int(round(10*i))
        df = play_game!(df, range, K)
    end
    sort!(df, :score)
    return df
end

function simulate!(df, rounds)
    @showprogress for round in 1:rounds
        df = play_round!(df, round)
    end
    return df
end

df = simulate!(df, 1)

CSV.write("out.csv",df)
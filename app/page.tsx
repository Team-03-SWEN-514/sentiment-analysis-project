"use client";

import { Amplify } from "aws-amplify";
import outputs from "@/amplify_outputs.json";
import {FormEvent, useState} from "react";
import axios from "axios";
import {Button, CircularProgress, Form, Input, Spinner, Tooltip} from "@heroui/react";

Amplify.configure(outputs);

// Axios API
const api = axios.create({
	baseURL: process.env.API_URL,
	withCredentials: true,
});

const submitQuery = async (query: string) =>
{
	if (query === '')
	{
		return (
			{
				status: 'error',
				message: 'Invalid query'
			}
		)
	}

	try
	{
		// TODO: API call
		// const response = await api.get(`/stock/${query}`);

		await new Promise(resolve => setTimeout(resolve, 1000));

		const response = {
			body: {
				Sentiment: {
					Sentiment: "POSITIVE",
					SentimentScore: {
						Positive: 0.6254,
						Negative: 0.0011,
						Neutral: 0.2346,
						Mixed: 0.1387
					}
				}
			}
		}

		return (
			{
				status: 'success',
				sentiment: response.body.Sentiment.Sentiment,
				metrics: {
					positive: response.body.Sentiment.SentimentScore.Positive,
					negative: response.body.Sentiment.SentimentScore.Negative,
					neutral: response.body.Sentiment.SentimentScore.Neutral,
					mixed: response.body.Sentiment.SentimentScore.Mixed,
				}
			}
		)
	}

	catch (e)
	{
		return (
			{
				status: 'error',
				message: 'Internal error'
			}
		)
	}
}

function InsetShadowOverlay({className=''}) {
	return (
		<div className={`
			absolute w-full h-full top-0 left-0
			rounded-lg
			pointer-events-none
			${className}
			[box-shadow:_inset_0_0px_4px_rgba(0,0,0,0.4)]
		`}/>
	);
}

const insetSectionBackgroundClassName = `
	bg-lgray-d bg-opacity-50
`;

const insetSectionClassName = `
	rounded-xl
	overflow-clip
	relative
`;

function InsetSection({children, className = ''}: {children?: React.ReactNode, className?: string}) {
	return (
		<div className={`
			${insetSectionClassName}
			${insetSectionBackgroundClassName}
			${className}
		`}>
			{children}
			<InsetShadowOverlay/>
		</div>
	);
}

interface IMetrics
{
	positive: number
	negative: number
	mixed: number
	neutral: number
}

interface IResult
{
	query: string
	status: string
	message?: string
	sentiment?: string
	metrics?: IMetrics
}

interface IMetricResultColors
{
	indicatorStroke: string
	trackStroke: string
	text: string
}

function MetricResult({metricName, metricValue, colors}: {metricName: string, metricValue?: number, colors: IMetricResultColors})
{
	const resolvedValue = metricValue ?? 0

	return (
		<div className={`flex flex-row place-items-center p-3 gap-3`}>
			<Tooltip content={`${resolvedValue * 100}%`} showArrow={true} placement="bottom">
				<CircularProgress
					size='lg'
					showValueLabel={true}
					value={resolvedValue * 100}
					formatOptions={{style: "decimal", maximumFractionDigits: 1}}
					classNames={{
						svg: "w-16 h-16 drop-shadow-md",
						indicator: colors.indicatorStroke,
						track: colors.trackStroke,
						value: `font-semibold ${colors.text} text-md`,
					}}
					strokeWidth={2}
				/>
			</Tooltip>
			<h3 className={`
				${colors.text}
				font-semibold
				text-2xl
			`}>{metricName}</h3>
		</div>
	)
}

export default function App()
{
	const [error, setError] = useState('');
	const [result, setResult] = useState<IResult>({} as IResult);
	const [loading, setLoading] = useState(false);

	const onSubmit = async (e: FormEvent<HTMLFormElement>) =>
	{
		e.preventDefault()

		setLoading(true)
		setResult({} as IResult)
		setError('')

		const data = Object.fromEntries(new FormData(e.currentTarget)) as { query: string };

		const result = await submitQuery(data.query);

		setLoading(false);
		setResult({
			query: data.query,
			...result
		})

		if (result.status !== 'success')
		{
			setError(result.message ?? '')
		}
	}

	return (
		<main className={`
			w-[100vw]
			h-[100vh]
			bg-red-500
			overflow-x-hidden
			overflow-y-hidden
			flex flex-col 
			justify-center
			justify-items-center
		`}>
			<div className={`
				mx-5 md:mx-0 md:w-1/2
				self-center
				p-1
				rounded-xl
				flex flex-col gap-1
			`}>
				<h1 className={`font-bold text-gray-100 text-2xl`}>
					Stock Sentiments
				</h1>
				<Form
					onSubmit={onSubmit}
					className={`
						flex flex-row
						gap-0
						drop-shadow-lg
					`}
				>
					<InsetSection className={`
						flex flex-row w-full
						gap-0
						bg-opacity-100
					`}>
						<Input
							label={`Stock Ticker`}
							labelPlacement='inside'
							placeholder={`VTI`}
							isClearable={true}
							maxLength={10}
							name={`query`}
							className={`h-[3.5rem] rounded-r-none`}
							classNames={{
								inputWrapper: 'rounded-r-none'
							}}
							type='text'
						/>
						<Button type={`submit`} className={`
							h-[3.5rem]
							rounded-l-none
							drop-shadow-lg
							bg-red-500
							text-gray-100
							font-medium
						`}>
							Submit
						</Button>
					</InsetSection>
				</Form>
				<InsetSection className={`
					h-[50vh] 
					bg-gray-200
					bg-opacity-100
				`}>
					<div className={`
						w-full h-full
						overflow-y-auto
						overflow-x-hidden
						relative
					`}>
						<div className={`
							w-full h-full
							flex flex-col
							justify-center
							justify-items-center
							${loading ? '' : 'hidden'}
						`}>
							<Spinner size='lg' classNames={
								{
									circle1: 'border-b-red-500',
									circle2: 'border-b-red-500'
								}
							}/>
						</div>
						<div className={`
							w-full h-full
							max-w-full
							
							flex flex-col
							${(result?.sentiment === undefined) ? 'hidden' : ''}
						`}>
							<div className={`
								px-5 pt-4 pb-1
								text-red-500
							`}>
								<h2 className={`
									
									text-xl font-bold
								`}>Analysis for '{result.query}'</h2>
								<p className={``}>Overall sentiment: {result.sentiment}</p>
							</div>
							<div className={`
								flex flex-col md:flex-row
								max-w-full
								flex-wrap
							`}>
								<MetricResult
									metricName={`Positive`}
									metricValue={result?.metrics?.positive}
									colors={{
										indicatorStroke: 'stroke-green-700',
										trackStroke: 'stroke-green-700/30',
										text: 'text-green-700'
									}}
								/>
								<MetricResult
									metricName={`Negative`}
									metricValue={result?.metrics?.negative}
									colors={{
										indicatorStroke: 'stroke-red-500',
										trackStroke: 'stroke-red-300',
										text: 'text-red-500'
									}}
								/>
								<MetricResult
									metricName={`Mixed`}
									metricValue={result?.metrics?.mixed}
									colors={{
										indicatorStroke: 'stroke-amber-500',
										trackStroke: 'stroke-amber-500/30',
										text: 'text-amber-500'
									}}
								/>
								<MetricResult
									metricName={`Neutral`}
									metricValue={result?.metrics?.neutral}
									colors={{
										indicatorStroke: 'stroke-gray-500',
										trackStroke: 'stroke-gray-500/30',
										text: 'text-gray-500'
									}}
								/>
							</div>
						</div>
						<div className={`
							w-full h-full
							flex flex-col
							justify-center
							justify-items-center
							text-center
							${error === '' ? 'hidden' : ''}
						`}>
							<p className={`text-red-500 font-bold text-xl`}>{error}</p>
						</div>
					</div>
				</InsetSection>
			</div>
		</main>
	);
}
